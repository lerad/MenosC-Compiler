#ifndef DEBUG_MSG_H
#define DEBUG_MSG_H
#include<sstream>

typedef std::stringstream ss;


  void DebugMsg(const char*);//print debug message to stdout
  void DebugStream(const ss&);//print debug message to stdout, eg Debug.Stream(ss() << "loremipsum" << 22 )
  void DebugEnterLevel();//print entering level info
  void DebugEndLevel();//print ending level info

	#endif
