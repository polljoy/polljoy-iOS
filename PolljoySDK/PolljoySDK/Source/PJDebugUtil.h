//
//  PJDebugUtil.h
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#ifndef PJDebugUtil_h
#define PJDebugUtil_h


// disable for production mode
// #define PJ_DEBUG

#define _PJ_CLASS NSStringFromClass([self class])
#define _PJ_METHOD NSStringFromSelector(_cmd)


#ifdef PJ_DEBUG
    #define util_Log(format, ...) NSLog(format, ## __VA_ARGS__)
    #define util_Printf(format, ...) printf(format, ## __VA_ARGS__)
    #define util_DEBUG(codes) codes

#else
    #define util_Log(format, ...)
    #define util_Printf(format, ...)
    #define util_DEBUG(codes)
#endif

#endif

#define util_simplelog util_Log(@"[%@ %@]",_PJ_CLASS, _PJ_METHOD)

