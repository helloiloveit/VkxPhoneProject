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

# Utility rule file for svncheck.

# Include the progress variables for this target.
include CMakeFiles/svncheck.dir/progress.make

CMakeFiles/svncheck:
	cd $(CMAKE_SOURCE_DIR) && LC_ALL=C git status | grep -q nothing\ to\ commit\ .working\ directory\ clean.

svncheck: CMakeFiles/svncheck
svncheck: CMakeFiles/svncheck.dir/build.make
.PHONY : svncheck

# Rule to build all files generated by this target.
CMakeFiles/svncheck.dir/build: svncheck
.PHONY : CMakeFiles/svncheck.dir/build

CMakeFiles/svncheck.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/svncheck.dir/cmake_clean.cmake
.PHONY : CMakeFiles/svncheck.dir/clean

CMakeFiles/svncheck.dir/depend:
	cd /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build-armv7-apple-darwin/externals/zrtpcpp && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/externals/zrtpcpp /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/externals/zrtpcpp /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build-armv7-apple-darwin/externals/zrtpcpp /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build-armv7-apple-darwin/externals/zrtpcpp /Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build-armv7-apple-darwin/externals/zrtpcpp/CMakeFiles/svncheck.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/svncheck.dir/depend

