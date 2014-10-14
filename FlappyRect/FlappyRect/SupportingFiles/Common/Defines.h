//
//  Defines.h
//  FlappyRect
//
//  Created by Pandara on 14-10-1.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

#ifndef FlappyRect_Defines_h
#define FlappyRect_Defines_h

#define DEVICE_BOUNDS [[UIScreen mainScreen] applicationFrame]
#define DEVICE_SIZE [[UIScreen mainScreen] applicationFrame].size
#define WINDOW_SIZE [[UIApplication sharedApplication] keyWindow].frame.size
#define DELTA_Y ( DEVICE_OS_VERSION >= 7.0f? 20.0f:0.0f)

#define color(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define DEVICE_OS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#endif
