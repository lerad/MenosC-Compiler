#ifndef DEBUG_MSG_H
#define DEBUG_MSG_H
#include<sstream>

#define DebugStream(x) do{std::stringstream sst; sst << x; DebugMsg(sst.str().c_str()); }while(0)


  void DebugMsg(const char*);//print debug message to stdout
  void DebugEnterLevel();//print entering level info
  void DebugEndLevel();//print ending level info

	#endif
