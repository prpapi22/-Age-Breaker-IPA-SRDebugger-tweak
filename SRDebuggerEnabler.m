  void *(*getSR)(void*) = (void*(*)(void*))(b+0x5C0E324);
  void (*setTrig)(void*,bool,void*) = (void(*)(void*,bool,void*))(b+0x5C2A8E8);
  bool (*getTrig)(void*,void*) = (bool(*)(void*,void*))(b+0x5C2A834);
  void (*showPanel)(void*,bool,void*) = (void(*)(void*,bool,void*))(b+0x5C2ADD8);

  void *sr = getSR(NULL);
  L([NSString stringWithFormat:@"SRDebug.Instance=%p",sr]);
  if(sr){
    setTrig(sr,true,NULL);
    L([NSString stringWithFormat:@"trigger enabled=%d",getTrig(sr,NULL)]);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,3*NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
      showPanel(sr,false,NULL);
      L(@"panel shown");
    });
  }
