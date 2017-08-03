
                      T4 Build Tasks NuGet package ReadMe
                      ===================================

  I. Overview
 II. What to do once you've installed this package
III. Sample T4 stuff
 IV. Known problems
  V. More information


I. Overview

The Text Template Transformation Toolkit (T4) is a powerful tool, but has to be
run manually. This package contains the files (a couple DLLs and a .targets
file) necessary to perform T4 tasks during a build. This version of the package
supports Visual Studio 2013, 2015, and 2017.

II. What to do once you've installed this package

You've just added the T4 Build Tasks package to your project. Now what?

Now you can use the powerful T4 engine to perform transformations at build
time. When you add the package to a project, it should automatically edit your
project file to import the Unofficial.
Microsoft.TextTemplating.BuildTasks.targets file.  But that won't make any
difference in your build until you add some some files to the TransformOnBuild
property group.

For example, when you added the Unofficial.Microsoft.TextTemplating.BuildTasks
package, you should get a line like this added near the bottom of your msbuild
project file:

    <Import Project="..\packages\Unofficial.Microsoft.TextTemplating.BuildTasks.15.0.0.0\build\Unofficial.Microsoft.TextTemplating.BuildTasks.targets" Condition="Exists('..\packages\Microsoft.TextTemplating.BuildTasks.15.0.0.0\build\Unofficial.Microsoft.TextTemplating.BuildTasks.targets')" />

(You might also get some additional goo after that if you have enabled NuGet
Package Restore.)

Somewhere after that <Import> statement, you can now add something like this:

    <ItemGroup>
      <!--
        This is how we can pass parameters to the T4 engine, so that 'parameter' directives will work. Ex:

          <#@ parameter type="System.String" name="PlatformName" #>
      -->
      <T4ParameterValues Include="SolutionDir">
        <Value>$(SolutionDir)</Value>
        <Visible>false</Visible> <!-- so that it won't show up in the Solution Explorer -->
      </T4ParameterValues>
      <T4ParameterValues Include="Configuration">
        <Value>$(Configuration)</Value>
        <Visible>false</Visible>
      </T4ParameterValues>
      <T4ParameterValues Include="PlatformName">
        <Value>$(PlatformName)</Value>
        <Visible>false</Visible>
      </T4ParameterValues>
    </ItemGroup>
    <PropertyGroup>
      <TransformOnBuild>true</TransformOnBuild>
      <!-- Other properties can be inserted here -->
    </PropertyGroup>

This enables T4 transforms to be run during your build process. Next, you need
to add some files to be transformed. For example (these don't have to come at
the bottom of the file after the <import>; they can be anywhere):

    <ItemGroup>
      <T4Transform Include="Something.tt">
        <OutputFilePath>$(OutputPath)</OutputFilePath> <!-- Where the generated file should go -->
      </T4Transform>
      <T4Transform Include="AnotherSomething.tt">
        <OutputFilePath>$(OutputPath)</OutputFilePath>
      </T4Transform>
      <!-- Append these to the FileWrites group so that they will get deleted upon executing the 'Clean' target. -->
      <FileWrites Include="$(OutputPath)Something.myExt">
        <Visible>false</Visible> <!-- so that it won't show up in the Solution Explorer -->
      </FileWrites>
      <FileWrites Include="$(OutputPath)AnotherSomething.myExt">
        <Visible>false</Visible> <!-- so that it won't show up in the Solution Explorer -->
      </FileWrites>
      <FileWrites Include="$(TrackerLogDirectory)*.tlog">
        <Visible>false</Visible> <!-- so that it won't show up in the Solution Explorer -->
      </FileWrites>
    </ItemGroup>

Now your files will be transformed whenever you build your project. Yay!

III. Sample T4 stuff

For people who are new to T4 transformations, we'll give some sample content,
demonstrating enough T4 technique that you can do sophisticated things with it.

What does that "Something.tt" file (from the <ItemGroup> above) look like? It
could look like this:

    <#@ template debug="true" hostspecific="true" language="C#" #>

    Some introductory content stuff blah blah

    <#  // We can also inject content via code:
        Write( @"

        WARNING: This is generated stuff; do not edit directly

    " );
    #>
    <# // and we can "pound-include" other things: #>
    <#@ include file="FormatTemplate.t4" #>
    <#@ include file="Something.myExt.in" #>

And AnotherSomething.tt might be similar, but include a different ".in" file.

Here is "FormatTemplate.t4":

    <#@ assembly name="System.Core" #>
    <#@ assembly name="EnvDTE" #>
    <#@ import namespace="System.Linq" #>
    <#@ import namespace="System.Text" #>
    <#@ import namespace="System.IO" #>
    <#@ import namespace="System.Collections.Generic" #>
    <#@ import namespace="EnvDTE" #>
    <#@ output extension=".myExt" #>
    <#@ parameter type="System.String" name="SolutionDir" #>
    <#@ parameter type="System.String" name="Configuration" #>
    <#@ parameter type="System.String" name="PlatformName" #>
    <#
        bool isDebug = 0 == StringComparer.OrdinalIgnoreCase.Compare( "Debug", Configuration );
        bool is32Bit = 0 == StringComparer.OrdinalIgnoreCase.Compare( "x86", PlatformName );
        // other common code here
    #>

And here is "Something.myExt.in":

    This is is text that will show up in the output file.

    Lorem ipsum dolor something something blah blah blah.
    <# if( is32Bit ) { #>

    This is my 32-bit content.

    <# } else { #>

    This is my non-32-bit content.

    <# } #>

    More content...

    <# if( isDebug ) { #>

    This is my debug content.

    <# } else { #>

    This is my non-debug content.

    <# } #>

    More stuff...


IV. Known problems

If you enable "NuGet Package Restore" for your solution, and have a working
copy that does not have the Unofficial.Microsoft.TextTemplating.BuildTasks
package installed, then the package will be restored the first time you build.
However, the transformation targets will not be run. Therefore, if you depend
on package restore to pull down the
Unofficial.Microsoft.TextTemplating.BuildTasks package, you'll need to build
twice the first time you clone a new directory.

V. More information

You can find more information about T4 on MSDN and Oleg Sych's blog:

http://msdn.microsoft.com/en-us/library/bb126445.aspx
http://www.olegsych.com/

This NuGet package is not "official": it is not produced by the T4 team. If you
think it's useful, let them know that you'd like to see an /official/ NuGet
package.

Feedback on this NuGet package, but not about T4, can be directed to
dan_j_thompson@hotmail.com.

