/** @internal
 ** @file     sift.c
 ** @author   Andrea Vedaldi
 ** @brief    Scale Invariant Feature Transform (SIFT) - MEX
 **/

/*
Copyright (C) 2007-12 Andrea Vedaldi and Brian Fulkerson.
All rights reserved.

This file is part of the VLFeat library and is made available under
the terms of the BSD license (see the COPYING file).
*/

#include <mexutils.h>
#include <vl/mathop.h>
#include <vl/sift.h>

#include <math.h>
#include <assert.h>

/* option codes */
enum {
  opt_octaves = 0,
  opt_levels,
  opt_first_octave,
  opt_frames,
  opt_edge_thresh,
  opt_peak_thresh,
  opt_norm_thresh,
  opt_magnif,
  opt_window_size,
  opt_orientations,
  opt_float_descriptors,
  opt_verbose
} ;

/* options */
vlmxOption  options [] = {
  {"Octaves",          1,   opt_octaves           },
  {"Levels",           1,   opt_levels            },
  {"FirstOctave",      1,   opt_first_octave      },
  {"Frames",           1,   opt_frames            },
  {"PeakThresh",       1,   opt_peak_thresh       },
  {"EdgeThresh",       1,   opt_edge_thresh       },
  {"NormThresh",       1,   opt_norm_thresh       },
  {"Magnif",           1,   opt_magnif            },
  {"WindowSize",       1,   opt_window_size       },
  {"Orientations",     0,   opt_orientations      },
  {"FloatDescriptors", 0,   opt_float_descriptors },
  {"Verbose",          0,   opt_verbose           },
  {0,                  0,   0                     }
} ;

/** ------------------------------------------------------------------
 ** @internal
 ** @brief Transpose desriptor
 **
 ** @param dst destination buffer.
 ** @param src source buffer.
 **
 ** The function writes to @a dst the transpose of the SIFT descriptor
 ** @a src. The tranpsose is defined as the descriptor that one
 ** obtains from computing the normal descriptor on the transposed
 ** image.
 **/

VL_INLINE void
transpose_descriptor (vl_sift_pix* dst, vl_sift_pix* src)
{
  int const BO = 8 ;  /* number of orientation bins */
  int const BP = 4 ;  /* number of spatial bins     */
  int i, j, t ;

  for (j = 0 ; j < BP ; ++j) {
    int jp = BP - 1 - j ;
    for (i = 0 ; i < BP ; ++i) {
      int o  = BO * i + BP*BO * j  ;
      int op = BO * i + BP*BO * jp ;
      dst [op] = src[o] ;
      for (t = 1 ; t < BO ; ++t)
        dst [BO - t + op] = src [t + o] ;
    }
  }
}

/** ------------------------------------------------------------------
 ** @internal
 ** @brief Ordering of tuples by increasing scale
 **
 ** @param a tuple.
 ** @param b tuple.
 **
 ** @return @c a[2] < b[2]
 **/

static int
korder (void const* a, void const* b) {
  double x = ((double*) a) [2] - ((double*) b) [2] ;
  if (x < 0) return -1 ;
  if (x > 0) return +1 ;
  return 0 ;
}

/** ------------------------------------------------------------------
 ** @internal
 ** @brief Check for sorted keypoints
 **
 ** @param keys keypoint list to check
 ** @param nkeys size of the list.
 **
 ** @return 1 if the keypoints are storted.
 **/

vl_bool
check_sorted (double const * keys, vl_size nkeys)
{
  vl_uindex k ;
  for (k = 0 ; k + 1 < nkeys ; ++ k) {
    if (korder(keys, keys + 4) > 0) {
      return VL_FALSE ;
    }
    keys += 4 ;
  }
  return VL_TRUE ;
}

/** ------------------------------------------------------------------
 ** @brief MEX entry point
 **/

void
mexFunction(int nout, mxArray *out[],
            int nin, const mxArray *in[])
{

  enum {IN_I=0,IN_END} ;
  enum {OUT_FRAMES=0, OUT_DESCRIPTORS} ;

  int                verbose = 0 ;
  int                opt ;
  int                next = IN_END ;
  mxArray const     *optarg ;

  vl_sift_pix const *data ;
  int                M, N ;

  int                O     = - 1 ;
  int                S     =   3 ;
  int                o_min =   0 ;

  double             edge_thresh = -1 ;
  double             peak_thresh = -1 ;
  double             norm_thresh = -1 ;
  double             magnif      = -1 ;
  double             window_size = -1 ;

  mxArray           *ikeys_array = 0 ;
  double            *ikeys = 0 ;
  int                nikeys = -1 ;
  vl_bool            force_orientations = 0 ;
  vl_bool            floatDescriptors = 0 ;

  VL_USE_MATLAB_ENV ;

  /* -----------------------------------------------------------------
   *                                               Check the arguments
   * -------------------------------------------------------------- */

  if (nin < 1) {
    mexErrMsgTxt("One argument required.") ;
  } else if (nout > 2) {
    mexErrMsgTxt("Too many output arguments.");
  }

  if (mxGetNumberOfDimensions (in[IN_I]) != 2              ||
      mxGetClassID            (in[IN_I]) != mxSINGLE_CLASS  ) {
    mexErrMsgTxt("I must be a matrix of class SINGLE") ;
  }

  data = (vl_sift_pix*) mxGetData (in[IN_I]) ;
  M    = mxGetM (in[IN_I]) ;
  N    = mxGetN (in[IN_I]) ;

  while ((opt = vlmxNextOption (in, nin, options, &next, &optarg)) >= 0) {
    switch (opt) {

    case opt_verbose :
      ++ verbose ;
      break ;

    case opt_frames :
      if (!vlmxIsMatrix(optarg, 4, -1)) {
        mexErrMsgTxt("'Frames' must be a 4 x N matrix.") ;
      }
      ikeys_array = mxDuplicateArray (optarg) ;
      nikeys      = mxGetN (optarg) ;
      ikeys       = mxGetPr (ikeys_array) ;
      if (! check_sorted (ikeys, nikeys)) {
        qsort (ikeys, nikeys, 4 * sizeof(double), korder) ;
      }
      break ;

    default :
		mexPrintf("Fuck you!");
      abort() ;
    }
  }
  
  /* -----------------------------------------------------------------
   *                                                            Do job
   * -------------------------------------------------------------- */
  {
    VlSiftFilt        *filt ;
    vl_bool            first ;
    double            *frames = 0 ;
    void              *descr  = 0 ;
    int                nframes = 0, reserved = 0, i,j,q ;

    /* create a filter to process the image */
    filt = vl_sift_new (M, N, O, S, o_min) ;

	//mexPrintf("%f %f %f \n%f %f %f %f %f\n",(float)O,(float)S,(float)o_min,(float)peak_thresh
	//	,(float)edge_thresh,(float)norm_thresh,(float)magnif,(float)window_size);


    /* ...............................................................
     *                                             Process each octave
     * ............................................................ */
    i     = 0 ;
    first = 1 ;
    while (first == 1) {
      int                   err ;
      VlSiftKeypoint const *keys  = 0 ;
      int                   nkeys = 0 ;


        err   = vl_sift_process_first_octave (filt, data) ;
        first = 0 ;

      if (err) break ;

      /* Run detector ............................................. */
        nkeys = nikeys ;

	  //mexPrintf("Zhu: entering sweeping nkeys, nkeys = %d, i = %d \n", nkeys, i);

      /* For each keypoint ........................................ */
		for (; i < nkeys ; ++i) {
			int h;
			vl_sift_pix  buf[128];
			vl_sift_pix rbuf[128];
        double                angle;
        VlSiftKeypoint        ik ;
        VlSiftKeypoint const *k ;

        /* Obtain keypoint orientations ........................... */
          vl_sift_keypoint_init (filt, &ik,
                                 ikeys [4 * i + 1] - 1,
                                 ikeys [4 * i + 0] - 1,
                                 ikeys [4 * i + 2]) ;
		  //mexPrintf("ikeys: [%f, %f, %f]\n", (float)(ikeys [4 * i + 1] - 1), (float)(ikeys [4 * i + 0] - 1), (float)(ikeys [4 * i + 2]) );

          k = &ik ;

          /* optionally compute orientations too */
            angle = VL_PI / 2 - ikeys [4 * i + 3] ;
			q = 0;

		  
		  /* compute descriptor (if necessary) */
		  //int h;
		  //mexPrintf("M = %d, N = %d.\n",M,N);
		  //for (h = 0; h < 300; h++) 
		  //{
			//  mexPrintf("%f ",data[h]);
			//  if (h % 8 == 7) mexPrintf("\n");
		  //}
          if (nout > 1) {
			  //mexPrintf("angles = %f, x = %f(%d), y = %f(%d), s = %f(%d), o = %d, sigma = %f.\n buf = [", 
				  //angle,k->x,k->ix,k->y,k->iy,k->s,k->is,k->o,k->sigma);
			  vl_sift_calc_keypoint_descriptor (filt, buf, k, angle) ;
			  //for (h = 0; h < 128; h++) 
			  //{
				//  mexPrintf("%f ",(float)buf[h]);
				//  if (h % 8 == 7) mexPrintf("\n");
			  //}
			  //mexPrintf("...].\nrbuf = [");
			  transpose_descriptor (rbuf, buf) ;
			  //for (h = 0; h < 128; h++) 
			  //{
				//  mexPrintf("%f ",(float)rbuf[h]);
				//  if (h % 8 == 7) mexPrintf("\n");
			  //}
			  //mexPrintf("...].\n");
          }

          /* make enough room for all these keypoints and more */
          if (reserved < nframes + 1) {
            reserved += 2 * nkeys ;
            frames = mxRealloc (frames, 4 * sizeof(double) * reserved) ;
            if (nout > 1) {
              if (! floatDescriptors) {
                descr  = mxRealloc (descr,  128 * sizeof(vl_uint8) * reserved) ;
              } else {
                descr  = mxRealloc (descr,  128 * sizeof(float) * reserved) ;
              }
            }
          }

          /* Save back with MATLAB conventions. Notice tha the input
           * image was the transpose of the actual image. */
          frames [4 * nframes + 0] = k -> y + 1 ;
          frames [4 * nframes + 1] = k -> x + 1 ;
          frames [4 * nframes + 2] = k -> sigma ;
          frames [4 * nframes + 3] = VL_PI / 2 - angle;

		  //mexPrintf("Zhu: %d\n", nframes);
          if (nout > 1) {
            if (! floatDescriptors) {
              for (j = 0 ; j < 128 ; ++j) {
                float x = 512.0F * rbuf [j] ;
                x = (x < 255.0F) ? x : 255.0F ;
                ((vl_uint8*)descr) [128 * nframes + j] = (vl_uint8) x ;
              }
            } else {
              for (j = 0 ; j < 128 ; ++j) {
                float x = 512.0F * rbuf [j] ;
                ((float*)descr) [128 * nframes + j] = x ;
              }
            }
          }

          ++ nframes ;
         /* next orientation */
      } /* next keypoint */
	  //break;
	  //mexPrintf("Zhu: skip subsequent octave\n");
    } /* next octave */

	//mexPrintf("nframes_tot = %d\n",nframes);

    /* ...............................................................
     *                                                       Save back
     * ............................................................ */

    {
      mwSize dims [2] ;

      /* create an empty array */
      dims [0] = 0 ;
      dims [1] = 0 ;
      out[OUT_FRAMES] = mxCreateNumericArray
        (2, dims, mxDOUBLE_CLASS, mxREAL) ;

      /* set array content to be the frames buffer */
      dims [0] = 4 ;
      dims [1] = nframes ;
      mxSetPr         (out[OUT_FRAMES], frames) ;
      mxSetDimensions (out[OUT_FRAMES], dims, 2) ;

      if (nout > 1) {

        /* create an empty array */
        dims [0] = 0 ;
        dims [1] = 0 ;
        out[OUT_DESCRIPTORS]= mxCreateNumericArray
          (2, dims,
           floatDescriptors ? mxSINGLE_CLASS : mxUINT8_CLASS,
           mxREAL) ;

        /* set array content to be the descriptors buffer */
        dims [0] = 128 ;
        dims [1] = nframes ;
        mxSetData       (out[OUT_DESCRIPTORS], descr) ;
        mxSetDimensions (out[OUT_DESCRIPTORS], dims, 2) ;
      }
    }

    /* cleanup */
    vl_sift_delete (filt) ;

    if (ikeys_array)
      mxDestroyArray(ikeys_array) ;

  } /* end: do job */
}
