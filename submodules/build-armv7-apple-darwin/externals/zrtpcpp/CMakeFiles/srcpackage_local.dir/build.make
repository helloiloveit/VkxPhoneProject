# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /opt/local/bin/cmake

# The command to remove a file.
RM = /opt/local/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The program to use to edit the cache.
CMAKE_EDIT_COMMAND = /opt/local/bin/ccmake

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/externals/zrtpcpp

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build-armv7-apple-darwin/externals/zrtpcpp

# Utility rule file for srcpackage_local.

# Include the progress variables for this target.
include CMakeFiles/srcpackage_local.dir/progress.make

CMakeFiles/srcpackage_local:
	/opt/local/bin/cmake -E remove /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build-armv7-apple-darwin/externals/zrtpcpp/package/*.tar.bz2
	/opt/local/bin/gmake package_source
	/opt/local/bin/cmake -E copy libzrtpcpp-2.1.0.tar.bz2 /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build-armv7-apple-darwin/externals/zrtpcpp/package
	/opt/local/bin/cmake -E remove libzrtpcpp-2.1.0.tar.bz2

srcpackage_local: CMakeFiles/srcpackage_local
srcpackage_local: CMakeFiles/srcpackage_local.dir/build.make
.PHONY : srcpackage_local

# Rule to build all files generated by this target.
CMakeFiles/srcpackage_local.dir/build: srcpackage_local
.PHONY : CMakeFiles/srcpackage_local.dir/build

CMakeFiles/srcpackage_local.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/srcpackage_local.dir/cmake_clean.cmake
.PHONY : CMakeFiles/srcpackage_local.dir/clean

CMakeFiles/srcpackage_local.dir/depend:
	cd /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build-armv7-apple-darwin/externals/zrtpcpp && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/externals/zrtpcpp /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/externals/zrtpcpp /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build-armv7-apple-darwin/externals/zrtpcpp /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build-armv7-apple-darwin/externals/zrtpcpp /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build-armv7-apple-darwin/externals/zrtpcpp/CMakeFiles/srcpackage_local.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/srcpackage_local.dir/depend

