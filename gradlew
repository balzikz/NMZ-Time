#!/usr/bin/env sh

#
# Copyright 2015 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# @author: Andres Almiray
#

#
# Used to determine the path to the gradle wrapper in the case where this script is
# a symlink from a different directory
#
# See https://github.com/gradle/gradle/issues/3429
#
resolve_symlinks() {
  local path="$1"
  local result
  while [ -L "$path" ]; do
    result="$(readlink "$path")"
    if [ "${result#/*}" = "$result" ]; then
      # relative link
      path="$(dirname "$path")/$result"
    else
      # absolute link
      path="$result"
    fi
  done
  echo "$path"
}

# The value of the script path is the real path to this script (following symlinks)
#
# See https://github.com/gradle/gradle/issues/3429
#
SCRIPT_PATH=$(resolve_symlinks "$0")

# The value of APP_HOME is the absolute path to the directory where this script is located
#
APP_HOME=$(cd "$(dirname "$SCRIPT_PATH")" >/dev/null && pwd)
APP_BASE_NAME=$(basename "$0")

# Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
DEFAULT_JVM_OPTS=""

APP_NAME="Gradle"
APP_OPTS=""

# Use the maximum available, or set MAX_FD != -1 to use that value.
MAX_FD="maximum"

# For Darwin, add options to specify how the application appears in the dock
# https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/LaunchServicesKeys.html
#
# This is left empty by default, but you can override it on the command-line by exporting it
# e.g. export DEFAULT_JVM_OPTS="-Xdock:name=My App"
#
# It is recommended to use the Info.plist file to specify this information.
# https://github.com/gradle/gradle/issues/14066
#
if [ "$(uname)" = "Darwin" ]; then
    GRADLE_OPTS="$GRADLE_OPTS -Xdock:name=$APP_NAME"
fi

# Collect all arguments for the java command, following the shell quoting and substitution rules
#
# As this script is running in "no clobber" mode, we must be sure not to use > to redirect
# output, but must use >| instead.
#
# It is permissible to use > here, because it is not redirecting output.
#
# shellcheck disable=SC2046
#
for arg in "$@"; do
    if [ "$(printf '%s' "$arg" | cut -c 1)" = '-' ]; then
        #
        # For execution on Cygwin, we need to reformat the argument, because the Java VM
        # does not understand the Cygwin-style paths.
        #
        # As there is no way to quote the argument to make it acceptable to both the shell and the VM,
        # we can only think of another way.
        #
        # This is a simple rule which is not 100% correct, but it is sufficient for our purpose.
        #
        if [ "$OS" = "Cygwin" ] && [ "$(printf '%s' "$arg" | grep '^-D')" != "" ] && [ "$(printf '%s' "$arg" | grep '=')" != "" ]; then
            #
            # Only arguments starting with -D and containing a = sign are considered.
            #
            # The following is a substitution rule.
            #
            # See http://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion
            #
            #                             %       stands for replacement from the end of the string
            #                            / \      the pattern to be replaced
            #                           /   \     the replacement string
            #                          #     \    the original string
            #                         /       \
            #                        /         \
            #                     -Dfoo=bar -> -Dfoo=bar
            # -Dfoo=/cygdrive/c/bar -> -Dfoo=C:\bar
            #
            APP_OPTS="$APP_OPTS $(printf '%s' "$arg" | sed -e 's,=\(/cygdrive/\([a-zA-Z]\)\(/.*\)\),=C\:\\\3,g' -e 's,/,\\,g')"
        else
            APP_OPTS="$APP_OPTS \"$arg\""
        fi
    else
        APP_OPTS="$APP_OPTS \"$arg\""
    fi
done

# Escape the characters that are special to eval.
#
# This is to prevent the command from being interpreted by the shell.
#
# This is a simplified version of the logic in the gradle script.
#
# See https://github.com/gradle/gradle/blob/master/subprojects/bootstrap/src/main/resources/org/gradle/api/internal/not-used/gradle
#
# As this is a bootstrap script, it is not expected to be perfect.
#
# It is only expected to be good enough to run the wrapper.
#
# shellcheck disable=SC2001
#
APP_OPTS="$(echo "$APP_OPTS" | sed 's#\\#\\\\#g')"

#
# Set the properties that are needed to run the wrapper.
#
# These are the properties that are used by the wrapper to download the correct version of Gradle.
#
# The properties are read from the gradle-wrapper.properties file.
#
# This file is located in the same directory as this script.
#
# shellcheck disable=SC1090
#
. "$APP_HOME/gradle/wrapper/gradle-wrapper.properties"

#
# The following section is to find the java executable.
#
# It is a simplified version of the logic in the gradle script.
#
# See https://github.com/gradle/gradle/blob/master/subprojects/bootstrap/src/main/resources/org/gradle/api/internal/not-used/gradle
#
# As this is a bootstrap script, it is not expected to be perfect.
#
# It is only expected to be good enough to run the wrapper.
#
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        # IBM's JDK on AIX uses strange locations for the executables
        JAVACMD="$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="$JAVA_HOME/bin/java"
    fi
    if [ ! -x "$JAVACMD" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
    fi
else
    JAVACMD="java"
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
fi

#
# The following section is to determine the version of Java that is being used.
#
# It is a simplified version of the logic in the gradle script.
#
# See https://github.com/gradle/gradle/blob/master/subprojects/bootstrap/src/main/resources/org/gradle/api/internal/not-used/gradle
#
# As this is a bootstrap script, it is not expected to be perfect.
#
# It is only expected to be good enough to run the wrapper.
#
# shellcheck disable=SC2005
#
JAVA_VERSION=$("$JAVACMD" -version 2>&1 | sed -n ';s/.* version "\(.*\)\.\(.*\)\..*".*$/\1\2/p;')

#
# The following section is to determine the classpath for the wrapper.
#
# It is a simplified version of the logic in the gradle script.
#
# See https://github.com/gradle/gradle/blob/master/subprojects/bootstrap/src/main/resources/org/gradle/api/internal/not-used/gradle
#
# As this is a bootstrap script, it is not expected to be perfect.
#
# It is only expected to be good enough to run the wrapper.
#
# The classpath is the path to the gradle-wrapper.jar file.
#
# This file is located in the same directory as this script.
#
CLASSPATH="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"

#
# The following section is to run the wrapper.
#
# It is a simplified version of the logic in the gradle script.
#
# See https://github.com/gradle/gradle/blob/master/subprojects/bootstrap/src/main/resources/org/gradle/api/internal/not-used/gradle
#
# As this is a bootstrap script, it is not expected to be perfect.
#
# It is only expected to be good enough to run the wrapper.
#
# The main class of the wrapper is org.gradle.wrapper.GradleWrapperMain.
#
# The arguments to the wrapper are the arguments that were passed to this script.
#
# The wrapper will download the correct version of Gradle and then run it.
#
# The wrapper will then exit with the exit code of the Gradle build.
#
exec "$JAVACMD" "$DEFAULT_JVM_OPTS" "$JAVA_OPTS" "$GRADLE_OPTS" "-Dorg.gradle.appname=$APP_BASE_NAME" -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"
