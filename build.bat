:: this assumes MinGW/MSYS has been installed in  c:\mingw and curl (curl.haxx.se) is in the path
set MINGW_INSTOP=c:\mingw
set msys_bat=%MINGW_INSTOP%\msys\1.0\msys.bat
set inst_temp=c:\inst_temp\
if not exist %inst_temp%bin mkdir %inst_temp%bin
if not exist %inst_temp%lib mkdir %inst_temp%lib
if not exist %inst_temp%include mkdir %inst_temp%include

set LIB=%inst_temp%lib;%LIB%
set INCLUDE=%inst_temp%iinclude;%INCLUDE%

clone https://github.com/YannNayn/msvc_sup.git
pushd msvc_sup
nmake -f Makefile.msvc CFG=dll-release
popd
copy /Y msvc_sup\msvc100\src\dll-release\*.dll %inst_temp%bin
copy /Y msvc_sup\msvc100\src\dll-release\*.lib %inst_temp%lib
copy /Y msvc_sup\include\*.h %inst_temp%include

curl -o %inst_temp%lib\pthreadVC2.lib http://mirrors.kernel.org/sources.redhat.com/pthreads-win32/dll-latest/lib/x86/pthreadVC2.lib
curl -o %inst_temp%bin\pthreadVC2.dll http://mirrors.kernel.org/sources.redhat.com/pthreads-win32/dll-latest/dll/x86/pthreadVC2.dll

curl -o %inst_temp%include\pthread.h http://mirrors.kernel.org/sources.redhat.com/pthreads-win32/dll-latest/include/pthread.h
curl -o %inst_temp%include\sched.h http://mirrors.kernel.org/sources.redhat.com/pthreads-win32/dll-latest/include/sched.h
curl -o %inst_temp%include\semaphore.h http://mirrors.kernel.org/sources.redhat.com/pthreads-win32/dll-latest/include/semaphore.h

clone https://github.com/YannNayn/check_msvc.git
pushd check_msvc
set src_dir=%CD%
call %msys_bat% -c "cd %src_dir:\=/% && configure --prefix=%inst_temp:\=/% && make && make install"
LIB /DEF:src\.libs\libcheck-0.dll.def /MACHINE:X86 /OUT:%inst_temp%lib\libcheck.lib
popd

clone https://github.com/YannNayn/hsregex_msvc.git
pushd hsregex_msvc
nmake -f Makefile.msvc CFG=dll-release
popd

copy /Y hsregex_msvc\msvc100\src\dll-release\*.dll %inst_temp%bin
copy /Y hsregex_msvc\msvc100\src\dll-release\*.lib %inst_temp%lib
copy /Y hsregex_msvc\hsregex.h %inst_temp%include

clone https://github.com/YannNayn/galera_msvc.git
pushd galera_msvc
scons galerautils
scons gcache
scons galera
scons gcomm
scons gcs
scons garb
popd
copy /Y galera_msvc\galera_smm.dll %inst_temp%bin
git clone  https://github.com/YannNayn/mariadb-galera-msvc.git

::WIX environment variable is the wix (wix.sf.net) install path

set WIX_WCAUTIL_LIBRARY=%WIX%\SDK\VS2008\lib\x86\wcautil
set WIX_DUTIL_LIBRARY=%WIX%\SDK\VS2008\lib\x86\dutil
::this implies that VS2008 was found when installing WIX
if exist %WIX%\SDK\VS2008\inc set INCLUDE=%INCLUDE%;%WIX%\SDK\VS2008\inc&goto :done_wx_inc
if exist %WIX%\SDK\VS2010\inc set INCLUDE=%INCLUDE%;%WIX%\SDK\VS2010\inc&goto :done_wx_inc
echo Wix Include directory not found ...(w8 for updates ...)

goto :EOF

if not exist .build\nmake mkdir .build\nmake
pushd .build\nmake
set inst_temp_s=%inst_temp:\=/%
set DEFAULT_TMPDIR="c:\\temp"

:done_wx_inc
cmake -G "Nmake Makefiles"    -Wno-dev -DWITH_WSREP:BOOL=ON -DTMPDIR=%DEFAULT_TMPDIR% -DWIX_WCAUTIL_LIBRARY:FILE=%WIX_WCAUTIL_LIBRARY:\=/% -DWIX_DUTIL_LIBRARY:FILE=%WIX_DUTIL_LIBRARY:\=/%  -DWITH_EMBEDDED_SERVER=1 -DWITH_OQGRAPH:BOOL=FALSE -DWITH_ZLIB:STRING=system -DWITH_SSL:STRING=system -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo  -DCMAKE_INSTALL_PREFIX:PATH=%inst_temp_s% ..\..\mariadb-galera-msvc
nmake install
nmake dist

copy /Y Scripts\*.sh %inst_temp%\bin
copy /Y Scripts\*.sql %inst_temp%\bin
copy /Y Scripts\*.pl %inst_temp%\bin
popd


:: have a sh in the path(either cygwin or mingw as above )
