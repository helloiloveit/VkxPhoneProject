//
//  ConstantDefinition.h
//  linphone
//
//  Created by huyheo on 8/1/13.
//
//

#define DEBUG 1


#ifdef DEBUG
#	define DebugLog(format, ...) NSLog((@"<Debug>: %s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#	ifdef TRACE_LOG
#		define DebugTrace(format, ...) NSLog((@"<Trace>: %s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#	else
#		define DebugTrace(format, ...)
#	endif
#	define InfoLog(format, ...) NSLog((@"<Info> :%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#	define WarningLog(format, ...) NSLog((@"<Warning>: %s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#	define ErrorLog(format, ...) NSLog((@"<Error>: %s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#	define DebugLog(format, ...)
#	define DebugTrace(format, ...)
#	define InfoLog(format, ...) NSLog(@"<Info>: " format, ##__VA_ARGS__)
#	define WarningLog(format, ...) NSLog(@"<Warning>: " format, ##__VA_ARGS__)
#	define ErrorLog(format, ...) NSLog(@"<Error>: " format, ##__VA_ARGS__)
#endif





#define LINPHONE_ADDRESS 0