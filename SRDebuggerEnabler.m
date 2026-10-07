#import <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <string.h>
#include <stdbool.h>

static bool hk_true(void *s){ return true; }
static int  hk_zero(void *s){ return 0; }

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

typedef struct { uintptr_t rva; uint32_t expect; void *hook; const char *name; } T;

static void go(void){
  void (*Hook)(void*,void*,void**) = dlsym(RTLD_DEFAULT,"MSHookFunction");
  if(!Hook){ L(@"MSHookFunction not found"); return; }
  uintptr_t base = 0;
  for(uint32_t i=0;i<_dyld_image_count();i++){
    const char *n=_dyld_get_image_name(i);
    if(n && strstr(n,"UnityFramework.framework/UnityFramework")){
      base=(uintptr_t)_dyld_get_image_header(i); break; }
  }
  if(!base){ L(@"UnityFramework not found"); return; }
  L([NSString stringWithFormat:@"base=%p",(void*)base]);
  T t[] = {
    {0x5C0F494,0x39408000,hk_true,"IsEnabled"},
    {0x5C0F4A4,0xB9402800,hk_zero,"EnableTrigger"},
    {0x5C0F4AC,0xB9402C00,hk_zero,"TriggerBehaviour"},
    {0x5C0F7F0,0xB9409400,hk_zero,"TriggerPosition"},
    {0x5C0F828,0x39427000,hk_true,"EventSystem"},
  };
  for(int i=0;i<5;i++){
    uint32_t *p=(uint32_t*)(base+t[i].rva);
    L([NSString stringWithFormat:@"%s: %08x %08x (expect %08x)",t[i].name,p[0],p[1],t[i].expect]);
    if(p[0]!=t[i].expect){ L(@"  MISMATCH - skipped"); continue; }
    Hook(p,t[i].hook,NULL);
    L(@"  hooked");
  }
  L(@"done");
}

__attribute__((constructor)) static void init(void){
  L(@"loaded");
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW,6*NSEC_PER_SEC),
                 dispatch_get_main_queue(), ^{ go(); });
}
