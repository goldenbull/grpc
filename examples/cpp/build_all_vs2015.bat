@set nuget=%~dp0..\..\..\hush\nuget\nuget.exe
@pushd ..\..\
@call "%VS140COMNTOOLS%\vsvars32.bat"

@rem --------------------------------------------------------------------------------------
@title build protobuf to generate protoc.exe
pushd third_party\protobuf\cmake
cmake -G "Visual Studio 14 2015" -Dprotobuf_BUILD_TESTS=OFF . || goto :error
@rem for x64: cmake -G "Visual Studio 14 2015" -A "x64" -Dprotobuf_BUILD_TESTS=OFF . || goto :error
msbuild protobuf.sln /p:Configuration=Debug /m || goto :error
msbuild protobuf.sln /p:Configuration=Release /m || goto :error
popd

@rem --------------------------------------------------------------------------------------
@title build C# protobuf lib
pushd third_party\protobuf\csharp\src
%nuget% restore Google.Protobuf.sln || goto :error
msbuild Google.Protobuf.sln /p:Configuration=Debug /m || goto :error
msbuild Google.Protobuf.sln /p:Configuration=Release /m || goto :error
popd

@rem --------------------------------------------------------------------------------------
@title build grpc plugins for protoc.exe
pushd vsprojects
%nuget% restore grpc_protoc_plugins.sln || goto :error
msbuild grpc_protoc_plugins.sln /p:Configuration=Release /m || goto :error
popd

@rem --------------------------------------------------------------------------------------
@title build grpc C# extension x86
pushd vsprojects
%nuget% restore grpc_csharp_ext.sln || goto :error
msbuild grpc_csharp_ext.sln /t:grpc_csharp_ext /p:Configuration=Debug;Platform=Win32 /m || goto :error
msbuild grpc_csharp_ext.sln /t:grpc_csharp_ext /p:Configuration=Release;Platform=Win32 /m || goto :error
@title build grpc C# extension x64
msbuild grpc_csharp_ext.sln /t:grpc_csharp_ext /p:Configuration=Debug;Platform=x64 /m || goto :error
msbuild grpc_csharp_ext.sln /t:grpc_csharp_ext /p:Configuration=Release;Platform=x64 /m || goto :error
popd

@rem --------------------------------------------------------------------------------------
@title build grpc C# lib
pushd src\csharp
%nuget% restore Grpc.sln || goto :error
msbuild Grpc.sln /p:Configuration=Debug /m || goto :error
msbuild Grpc.sln /p:Configuration=Release /m || goto :error
popd

@rem --------------------------------------------------------------------------------------
@title build grpc lib x86
pushd vsprojects
%nuget% restore grpc-test.sln || goto :error
msbuild grpc-test.sln /t:helloworld /p:Configuration=Debug;Platform=Win32 /m || goto :error
msbuild grpc-test.sln /t:helloworld /p:Configuration=Release;Platform=Win32 /m || goto :error
@title build grpc lib x64
msbuild grpc-test.sln /t:helloworld /p:Configuration=Debug;Platform=x64 /m || goto :error
msbuild grpc-test.sln /t:helloworld /p:Configuration=Release;Platform=x64 /m || goto :error
popd

@echo *************** Success! ***************
@goto :end

:error
@echo *************** Failed! ***************

:end
popd
pause