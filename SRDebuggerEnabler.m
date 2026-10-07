#import <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#include <string.h>
#include <stdint.h> 

static void L(NSString *m){
  NSLog(@"[SRDE] %@", m);
  NSString *d = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
  NSString *p = [d stringByAppendingPathComponent:@"SRDE.log"];
  if(![[NSFileManager defaultManager] fileExistsAtPath:p])
    [@"" writeToFile:p atomically:YES encoding:NSUTF8StringEncoding error:nil];
  NSFileHandle *h=[NSFileHandle fileHandleForWritingAtPath:p];
  [h seekToEndOfFile];
  [h writeData:[[m stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
  [h closeFile];
}

static uintptr_t unity_base(void){
  for(uint32_t i=0;i<_dyld_image_count();i++){
    const char *n=_dyld_get_image_name(i);
    if(n && strstr(n,"UnityFramework.framework/UnityFramework"))
      return (uintptr_t)_dyld_get_image_header(i);
  }
  return 0;
}

static void go(void){
  uintptr_t b = unity_base();
  if(!b){ L(@"UnityFramework not found"); return; }
  L([NSString stringWithFormat:@"base=%p",(void*)b]);

  void *(*getInst)(void*) = (void*(*)(void*))(b+0x5C0E608);
  void  (*initSR)(void*)  = (void(*)(void*))(b+0x5C0E3B0);

  uint8_t *s = (uint8_t*)getInst(NULL);
  L([NSString stringWithFormat:@"Settings=%p",s]);
  if(!s || !*(uintptr_t*)(s+0x10)){ L(@"bad Settings object, aborting"); return; }

  *(uint8_t*)(s+0x20)  = 1;   // _isEnabled
  *(int32_t*)(s+0x28)  = 0;   // trigger mode: Enabled
  *(int32_t*)(s+0x2C)  = 0;   // TripleTap
  *(uint8_t*)(s+0x4F)  = 0;   // no entry code
  *(uint8_t*)(s+0x50)  = 0;
  *(int32_t*)(s+0x94)  = 0;   // TopLeft
  *(uint8_t*)(s+0x9C)  = 1;   // create EventSystem
  L(@"settings written");

  initSR(NULL);
  L(@"Init called");
}

__attribute__((constructor)) static void init(void){
  L(@"loaded");
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW,12*NSEC_PER_SEC),
                 dispatch_get_main_queue(), ^{ go(); });
}
