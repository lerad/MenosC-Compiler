#include <iostream>
#include <sstream>
#include "include/common.h"
//#include "include/"
using namespace std;

 void Msg(const char* msg)
	{	
 	#ifdef DEBUG
		cout <<"Debug@"<< yylineno <<":"<< msg << endl;
	#endif
	}

   void Stream(const stringstream &sst)
  {
		Msg(sst.str().c_str());
	}

 	
	 void DebugEnterLevel()
	{
		stringstream sst;
		sst << "Enter level " << level;
		Stream(sst);
	}


	
	 void DebugEndLevel()
	{
		stringstream sst;
		sst << "End of level " << level;
		Stream(sst);

	}
void DebugMsg(const char* msg)
{
  Msg(msg);

}



   /*
      void DebugStream(const ostream &o)
	{
  	stringstream sst;
	//cout << *o << endl;
	//sst << (dynamic_cast<const stringstream>(o));
	sst << o.rdbuf() << endl;

	Stream(sst);


}*/
	
 




