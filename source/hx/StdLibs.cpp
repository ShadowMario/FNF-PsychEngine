#include <hxcpp.h>
#include <hxMath.h>
#include <hx/Memory.h>
#include <hx/Thread.h>

#ifdef HX_WINDOWS
#include <windows.h>
#include <io.h>
#elif defined(__unix__) || defined(__APPLE__)
#include <sys/time.h>
#ifndef EMSCRIPTEN
typedef int64_t __int64;
#endif
#endif

#ifdef ANDROID
#include <android/log.h>
#endif
#ifdef WEBOS
#include <syslog.h>
#endif
#ifdef TIZEN
#include <dlog.h>
#endif
#if defined(BLACKBERRY) || defined(GCW0)
#include <unistd.h>
#endif
#include <string>
#include <map>
#include <stdio.h>
#include <time.h>
#include <clocale>


#ifdef HX_ANDROID
#define rand() lrand48()
#define srand(x) srand48(x)
#endif

#ifdef HX_WINRT
#define PRINTF WINRT_PRINTF
#elif defined(TIZEN)
#define PRINTF(fmt, ...) dlog_dprint(DLOG_INFO, "trace", fmt, __VA_ARGS__);
#elif defined(HX_ANDROID) && !defined(HXCPP_EXE_LINK)
#define PRINTF(fmt, ...) __android_log_print(ANDROID_LOG_INFO, "trace", fmt, __VA_ARGS__);
#elif defined(WEBOS)
#define PRINTF(fmt, ...) syslog(LOG_INFO, "trace", fmt, __VA_ARGS__);
#else
#define PRINTF printf
#endif

void __hx_stack_set_last_exception();
void __hx_stack_push_last_exception();

int _hxcpp_argc = 0;
char **_hxcpp_argv = 0;

namespace hx
{

Dynamic Throw(Dynamic inDynamic)
{
   #ifdef HXCPP_STACK_TRACE
   __hx_stack_set_last_exception();
   #endif
   throw inDynamic;
   return null();
}


Dynamic Rethrow(Dynamic inDynamic)
{
   #ifdef HXCPP_STACK_TRACE
   __hx_stack_push_last_exception();
   #endif
   throw inDynamic;
   return null();
}


null NullArithmetic(const char *inErr)
{
	Throw( String::create(inErr) );
	return null();
}

}

// -------- Resources ---------------------------------------

namespace hx
{

//typedef std::map<std::wstring,Resource> ResourceSet;
//static ResourceSet sgResources;

Resource *sgResources = 0;
Resource *sgSecondResources = 0;

void RegisterResources(Resource *inResources)
{
   if (sgResources)
      sgSecondResources = inResources;
   else
      sgResources = inResources;
}

}

using namespace hx;

Array<String> __hxcpp_resource_names()
{
   Array<String> result(0,0);

   if (sgResources)
      for(Resource *reso  = sgResources; reso->mData; reso++)
         result->push( reso->mName );

   if (sgSecondResources)
      for(Resource *reso  = sgSecondResources; reso->mData; reso++)
         result->push( reso->mName );

   return result;
}

String __hxcpp_resource_string(String inName)
{
   if (sgResources)
      for(Resource *reso  = sgResources; reso->mData; reso++)
      {
         if (reso->mName == inName)
         #if (HXCPP_API_LEVEL > 0)
         {
            #ifdef HX_SMART_STRINGS
            const unsigned char *p = reso->mData;
            for(int i=0;i<reso->mDataLength;i++)
               if (p[i]>127)
                  return String::create((const char *)p, reso->mDataLength);
            #endif
            return String((const char *) reso->mData, reso->mDataLength );
         }
         #else
            return String::create((const char *) reso->mData, reso->mDataLength );
         #endif
      }

   if (sgSecondResources)
   {
      for(Resource *reso  = sgSecondResources; reso->mData; reso++)
         if (reso->mName == inName)
         {
            #ifdef HX_SMART_STRINGS
            const unsigned char *p = reso->mData;
            for(int i=0;i<reso->mDataLength;i++)
               if (p[i]>127)
                  return _hx_utf8_to_utf16(p, reso->mDataLength,false);
            #endif
            return String((const char *) reso->mData, reso->mDataLength );

            return String((const char *) reso->mData, reso->mDataLength );
         }
   }
   return null();
}

Array<unsigned char> __hxcpp_resource_bytes(String inName)
{
   if (sgResources)
      for(Resource *reso  = sgResources; reso->mData; reso++)
      {
         if (reso->mName == inName)
         {
            int len = reso->mDataLength;
            Array<unsigned char> result( len, 0);
            memcpy( result->GetBase() , reso->mData, len );
            return result;
         }
      }
   if (sgSecondResources)
      for(Resource *reso  = sgSecondResources; reso->mData; reso++)
      {
         if (reso->mName == inName)
         {
            int len = reso->mDataLength;
            Array<unsigned char> result( len, 0);
            memcpy( result->GetBase() , reso->mData, len );
            return result;
         }
      }

   return null();
}

// -- hx::Native -------

#if HXCPP_API_LEVEL >= 330
extern "C" void __hxcpp_lib_main();
namespace hx
{
   const char *Init()
   {
      try
      {
         __hxcpp_lib_main();
         return 0;
      }
      catch(Dynamic e)
      {
         HX_TOP_OF_STACK
         return e->toString().utf8_str();
      }
   }
}
#endif


// --- System ---------------------------------------------------------------------

// --- Maths ---------------------------------------------------------
static double rand_scale = 1.0 / (1<<16) / (1<<16);
double __hxcpp_drand()
{
   unsigned int lo = rand() & 0xfff;
   unsigned int mid = rand() & 0xfff;
   unsigned int hi = rand() & 0xff;
   double result = (lo | (mid<<12) | (hi<<24) ) * rand_scale;
   return result;
}

int __hxcpp_irand(int inMax)
{
   unsigned int lo = rand() & 0xfff;
   unsigned int mid = rand() & 0xfff;
   unsigned int hi = rand() & 0xff;
   return (lo | (mid<<12) | (hi<<24) ) % inMax;
}

void __hxcpp_stdlibs_boot()
{
   #if defined(_MSC_VER) && !defined(HX_WINRT)
   HMODULE kernel32 = LoadLibraryA("kernel32");
   if (kernel32)
   {
      typedef BOOL (WINAPI *AttachConsoleFunc)(DWORD);
      typedef HWND (WINAPI *GetConsoleWindowFunc)(void);
      AttachConsoleFunc attach = (AttachConsoleFunc)GetProcAddress(kernel32,"AttachConsole");
      GetConsoleWindowFunc getConsole = (GetConsoleWindowFunc)GetProcAddress(kernel32,"GetConsoleWindow");
      if (attach && getConsole)
      {
         if (!attach( /*ATTACH_PARENT_PROCESS*/ (DWORD)-1 ))
         {
            //printf("Could not attach to parent console : %d\n",GetLastError());
         }
         else if (getConsole())
         {
            if (_fileno(stdout) < 0 || _get_osfhandle(fileno(stdout)) < 0)
               freopen("CONOUT$", "w", stdout);
            if (_fileno(stderr) < 0 || _get_osfhandle(fileno(stderr)) < 0)
               freopen("CONOUT$", "w", stderr);
            if (_fileno(stdin) < 0 || _get_osfhandle(fileno(stdin)) < 0)
               freopen("CONIN$", "r", stdin);
         }
      }
   }
   //_setmode(_fileno(stdout), 0x00040000); // _O_U8TEXT
   //_setmode(_fileno(stderr), 0x00040000); // _O_U8TEXT
   //_setmode(_fileno(stdin), 0x00040000); // _O_U8TEXT
   #endif

   // This is necessary for UTF-8 output to work correctly.
   setlocale(LC_ALL, "");
   setlocale(LC_NUMERIC, "C");

   // I think this does more harm than good.
   //  It does not cause fread to return immediately - as perhaps desired.
   //  But it does cause some new-line characters to be lost.
   //setbuf(stdin, 0);
   setbuf(stdout, 0);
   setbuf(stderr, 0);
}

void __trace(Dynamic inObj, Dynamic info)
{
   String text;
   if (inObj != null())
      text = inObj->toString();


   hx::strbuf convertBuf;
   if (info==null())
   {
      PRINTF("?? %s\n", text.raw_ptr() ? text.out_str(&convertBuf) : "null");
   }
   else
   {
      const char *filename = Dynamic((info)->__Field(HX_CSTRING("fileName"), HX_PROP_DYNAMIC))->toString().utf8_str(0,false);
      int line = Dynamic((info)->__Field( HX_CSTRING("lineNumber") , HX_PROP_DYNAMIC))->__ToInt();

      hx::strbuf convertBuf;
      //PRINTF("%s:%d: %s\n", filename, line, text.raw_ptr() ? text.out_str(&convertBuf) : "null");
      PRINTF("%s:%d: %s\n", filename, line, text.raw_ptr() ? text.out_str(&convertBuf) : "null");
   }

}

void __hxcpp_exit(int inExitCode)
{
   exit(inExitCode);
}

double  __time_stamp()
{
#ifdef HX_WINDOWS
   static __int64 t0=0;
   static double period=0;
   __int64 now;

   if (QueryPerformanceCounter((LARGE_INTEGER*)&now))
   {
      if (t0==0)
      {
         t0 = now;
         __int64 freq;
         QueryPerformanceFrequency((LARGE_INTEGER*)&freq);
         if (freq!=0)
            period = 1.0/freq;
      }
      if (period!=0)
         return (now-t0)*period;
   }
   return (double)clock() / ( (double)CLOCKS_PER_SEC);
#elif defined(__unix__) || defined(__APPLE__)
   static double t0 = 0;
   struct timeval tv;
   if( gettimeofday(&tv,0) )
      throw Dynamic("Could not get time");
   double t =  ( tv.tv_sec + ((double)tv.tv_usec) / 1000000.0 );
   if (t0==0) t0 = t;
   return t-t0;
#else
   return (double)clock() / ( (double)CLOCKS_PER_SEC);
#endif
}

#if defined(HX_WINDOWS) && !defined(HX_WINRT)

/*
ISWHITE and ParseCommandLine are based on the implementation of the
.NET Core runtime, CoreCLR, which is licensed under the MIT license:
Copyright (c) Microsoft. All rights reserved.
See LICENSE file in the CoreCLR project root for full license information.

The original source code of ParseCommandLine can be found in
https://github.com/dotnet/coreclr/blob/master/src/vm/util.cpp
*/

#define ISWHITE(x) ((x)==(' ') || (x)==('\t') || (x)==('\n') || (x)==('\r') )

static void ParseCommandLine(LPWSTR psrc, Array<String> &out)
{
    unsigned int argcount = 1;       // discovery of arg0 is unconditional, below

    bool    fInQuotes;
    int     iSlash;

    /* A quoted program name is handled here. The handling is much
       simpler than for other arguments. Basically, whatever lies
       between the leading double-quote and next one, or a terminal null
       character is simply accepted. Fancier handling is not required
       because the program name must be a legal NTFS/HPFS file name.
       Note that the double-quote characters are not copied, nor do they
       contribute to numchars.

       This "simplification" is necessary for compatibility reasons even
       though it leads to mishandling of certain cases.  For example,
       "c:\tests\"test.exe will result in an arg0 of c:\tests\ and an
       arg1 of test.exe.  In any rational world this is incorrect, but
       we need to preserve compatibility.
    */

    LPWSTR pStart = psrc;
    bool skipQuote = false;

    // Pairs of double-quotes vanish...
    while(psrc[0]=='\"' && psrc[1]=='\"')
       psrc += 2;

    if (*psrc == '\"')
    {
        // scan from just past the first double-quote through the next
        // double-quote, or up to a null, whichever comes first
        psrc++;
        while ((*psrc!= '\"') && (*psrc != '\0'))
        {
           psrc++;
           // Pairs of double-quotes vanish...
           while(psrc[0]=='\"' && psrc[1]=='\"')
              psrc += 2;
        }

        skipQuote = true;
    }
    else
    {
        /* Not a quoted program name */

        while (!ISWHITE(*psrc) && *psrc != '\0')
            psrc++;
    }

    // We have now identified arg0 as pStart (or pStart+1 if we have a leading
    // quote) through psrc-1 inclusive
    if (skipQuote)
        pStart++;
    String arg0("");
    while (pStart < psrc)
    {
        arg0 += String::fromCharCode(*pStart);
        pStart++;
    }
    // out.Add(arg0); // the command isn't part of Sys.args()

    // if we stopped on a double-quote when arg0 is quoted, skip over it
    if (skipQuote && *psrc == '\"')
        psrc++;

    while ( *psrc != '\0')
    {
LEADINGWHITE:

        // The outofarg state.
        while (ISWHITE(*psrc))
            psrc++;

        if (*psrc == '\0')
            break;
        else
        if (*psrc == '#')
        {
            while (*psrc != '\0' && *psrc != '\n')
                psrc++;     // skip to end of line

            goto LEADINGWHITE;
        }

        argcount++;
        fInQuotes = FALSE;

        String arg("");

        while ((!ISWHITE(*psrc) || fInQuotes) && *psrc != '\0')
        {
            switch (*psrc)
            {
            case '\\':
                iSlash = 0;
                while (*psrc == '\\')
                {
                    iSlash++;
                    psrc++;
                }

                if (*psrc == '\"')
                {
                    for ( ; iSlash >= 2; iSlash -= 2)
                    {
                        arg += String("\\");
                    }

                    if (iSlash & 1)
                    {
                        arg += String::fromCharCode(*psrc);
                        psrc++;
                    }
                    else
                    {
                        fInQuotes = !fInQuotes;
                        psrc++;
                    }
                }
                else
                    for ( ; iSlash > 0; iSlash--)
                    {
                        arg += String("\\");
                    }

                break;

            case '\"':
                fInQuotes = !fInQuotes;
                psrc++;
                break;

            default:
                arg += String::fromCharCode(*psrc);
                psrc++;
            }
        }

        out.Add(arg);
        arg = String("");
    }
}
#endif


#ifdef __APPLE__
 #if !defined(IPHONE) && !defined(APPLETV) && !defined(HX_APPLEWATCH)
   extern "C" {
   extern int *_NSGetArgc(void);
   extern char ***_NSGetArgv(void);
   }
 #endif
#endif
Array<String> __get_args()
{
   Array<String> result(0,0);
   if (_hxcpp_argc)
   {
      for(int i=1;i<_hxcpp_argc;i++)
         result->push( String::create(_hxcpp_argv[i],strlen(_hxcpp_argv[i])) );
      return result;
   }

   #ifdef HX_WINRT
   // Do nothing
   #elif defined(HX_WINDOWS)
   LPWSTR str =  GetCommandLineW();
   ParseCommandLine(str, result);
   #else
   #ifdef __APPLE__

   #if !defined(IPHONE) && !defined(APPLETV) && !defined(HX_APPLEWATCH)
   int argc = *_NSGetArgc();
   char **argv = *_NSGetArgv();
   for(int i=1;i<argc;i++)
      result->push( String::create(argv[i],strlen(argv[i])) );
   #endif

   #else
   #ifdef ANDROID
   // TODO: Get from java
   #elif defined(__linux__)
   char buf[80];
   sprintf(buf, "/proc/%d/cmdline", getpid());
   FILE *cmd = fopen(buf,"rb");
   bool real_arg = 0;
   if (cmd)
   {
      hx::QuickVec<char> arg;

      buf[0] = '\0';
      while (fread(buf, 1, 1, cmd))
      {
         if ((unsigned char)buf[0] == 0) // line terminator
         {
            if (real_arg)
               result->push( String::create(arg.mPtr, arg.mSize) );
            real_arg = true;
            arg.clear();
         }
         else
            arg.push(buf[0]);
      }
      fclose(cmd);
   }
   #endif

   #endif
   #endif
   return result;
}


void __hxcpp_print_string(const String &inV)
{
   hx::strbuf convertBuf;
   PRINTF("%s", inV.out_str(&convertBuf) );
}

void __hxcpp_println_string(const String &inV)
{
   hx::strbuf convertBuf;
   PRINTF("%s\n", inV.out_str(&convertBuf));
}


// --- Casting/Converting ---------------------------------------------------------


bool __instanceof(const Dynamic &inValue, const Dynamic &inType)
{
   if (inValue==null())
      return false;
   if (inType==hx::Object::__SGetClass())
      return true;
   hx::Class c = inType;
   if (c==null())
      return false;
   return c->CanCast(inValue.GetPtr());
}


int __int__(double x)
{
   #ifndef EMSCRIPTEN
   if (x < -0x7fffffff || x>0x7fffffff )
   {
      __int64 big_int = (__int64)(x);
      return big_int & 0xffffffff;
   }
   else
   #endif
      return (int)x;
}


static inline bool is_hex_string(const char *c, int len)
{
   return (len > 2 && c[0] == '0' && (c[1] == 'x' || c[1] == 'X'))
      || (len > 3 && (c[0] == '-' || c[0] == '+') && c[1] == '0' && (c[2] == 'x' || c[2] == 'X'));
}

Dynamic __hxcpp_parse_int(const String &inString)
{
   if (!inString.raw_ptr())
      return null();
   hx::strbuf buf;
   const char *str = inString.utf8_str(&buf);

   // On the first non space char check to see if we've got a hex string
   while (isspace(*str)) ++str;
   bool isHex = is_hex_string(str, strlen(str));
   char *end = 0;
   long result;
   if (isHex)
   {
      bool neg = str[0] == '-';
      if (neg) str++;
      result = strtoul(str,&end,16);
      if (neg) result = -result;
   }
   else 
      result = strtol(str,&end,10);
   #ifdef HX_WINDOWS
   if (str==end && !isHex)
   #else
   if (str==end)
   #endif
      return null();
   return (int)result;
}


double __hxcpp_parse_substr_float(const String &inString,int start, int length)
{
   if (start>=inString.length || length<1 || (start+length)>inString.length )
      return Math_obj::NaN;

   hx::strbuf buf;
   const char *str = inString.ascii_substr(&buf,start,length);
   char *end = (char *)str;
   double result = str ? strtod(str,&end) : 0;

   if (end==str)
      return Math_obj::NaN;

   return result;
}


double __hxcpp_parse_float(const String &inString)
{
   if (!inString.raw_ptr())
      return Math_obj::NaN;

   hx::strbuf buf;
   const char *str = inString.utf8_str(&buf);
   char *end = (char *)str;
   double result = str ? strtod(str,&end) : 0;

   if (end==str)
      return Math_obj::NaN;

   return result;
}


bool __hxcpp_same_closure(Dynamic &inF1,Dynamic &inF2)
{
   hx::Object *p1 = inF1.GetPtr();
   hx::Object *p2 = inF2.GetPtr();
   if (p1==0 || p2==0)
      return false;
   if ( (p1->__GetHandle() != p2->__GetHandle()))
      return false;
   return p1->__Compare(p2)==0;
}

namespace hx
{

struct VarArgFunc : public hx::Object
{
   HX_IS_INSTANCE_OF enum { _hx_ClassId = hx::clsIdClosure };

   VarArgFunc(Dynamic &inFunc) : mRealFunc(inFunc) {
     HX_OBJ_WB_NEW_MARKED_OBJECT(this)
   }

   int __GetType() const { return vtFunction; }
   ::String __ToString() const { return mRealFunc->__ToString() ; }

   void __Mark(hx::MarkContext *__inCtx) { HX_MARK_MEMBER(mRealFunc); }

   #ifdef HXCPP_VISIT_ALLOCS
   void __Visit(hx::VisitContext *__inCtx) { HX_VISIT_MEMBER(mRealFunc); }
   #endif

   void *__GetHandle() const { return mRealFunc.GetPtr(); }
   Dynamic __Run(const Array<Dynamic> &inArgs)
   {
      return mRealFunc->__run(inArgs);
   }

   Dynamic mRealFunc;
};

}

Dynamic __hxcpp_create_var_args(Dynamic &inArrayFunc)
{
   return Dynamic(new hx::VarArgFunc(inArrayFunc));
}

// --- CFFI helpers ------------------------------------------------------------------


// Field name management



static HxMutex sgFieldMapMutex;

typedef std::map<std::string,int> StringToField;

// These need to be pointers because of the unknown order of static object construction.
String *sgFieldToString=0;
int    sgFieldToStringSize=0;
int    sgFieldToStringAlloc=0;
StringToField *sgStringToField=0;

static String sgNullString;


const String &__hxcpp_field_from_id( int f )
{
   if (!sgFieldToString)
      return sgNullString;

   return sgFieldToString[f];
}


int  __hxcpp_field_to_id( const char *inFieldName )
{
   AutoLock lock(sgFieldMapMutex);

   if (!sgFieldToStringAlloc)
   {
      sgFieldToStringAlloc = 100;
      sgFieldToString = (String *)HxAlloc(sgFieldToStringAlloc * sizeof(String));

      sgStringToField = new StringToField;
   }

   std::string f(inFieldName);
   StringToField::iterator i = sgStringToField->find(f);
   if (i!=sgStringToField->end())
      return i->second;

   int result = sgFieldToStringSize;
   (*sgStringToField)[f] = result;
   String str(inFieldName,strlen(inFieldName));

   // Make into "const" string that will not get collected...
   str = String((char *)hx::InternalCreateConstBuffer(str.raw_ptr(),(str.length+1) * sizeof(char),true), str.length );

   if (sgFieldToStringAlloc<=sgFieldToStringSize+1)
   {
      int oldAlloc = sgFieldToStringAlloc;
      String *oldData = sgFieldToString;
      sgFieldToStringAlloc *= 2;
      String *newData = (String *)malloc(sgFieldToStringAlloc*sizeof(String));
      if (oldAlloc)
         memcpy(newData, oldData, oldAlloc*sizeof(String));
      // Let oldData dangle to keep it thread safe, rather than require mutex on id read.
      sgFieldToString = newData;
   }
   sgFieldToString[sgFieldToStringSize++] = str;
   return result;
}

// --- haxe.Int32 ---------------------------------------------------------------------
void __hxcpp_check_overflow(int x)
{
   if( (((x) >> 30) & 1) != ((unsigned int)(x) >> 31) )
      throw Dynamic(HX_CSTRING("Overflow ")+x);
}

// --- Memory ---------------------------------------------------------------------

unsigned char *__hxcpp_memory = 0;

void  __hxcpp_memory_memset(Array<unsigned char> &inBuffer ,int pos, int len, int value)
{
   if (pos<inBuffer->length)
   {
      if (pos+len>inBuffer->length)
         len = inBuffer->length - pos;
      if (len>0)
         memset( inBuffer->Pointer() + pos, value, len);
   }
}
