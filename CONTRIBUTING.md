TODO: contrib structure.


### Notes 
I originally created it to be able to format the code the way i like it, with the ability to have customizable styles.

The style of dart_style is not to my liking and that of many other people, or so I imagine, so something that started as a small patch to the original code became a fork to have more freedom in what commits are applied and in what way.

This led to wanting automatic formatting like Dart's analysis_server does, but analysis_plugins did not include the ability to hook calls to format code.

After a chat with one of the Dart team members they proposed me to create a simple server similar to what analysis_server does and so I started working about creating a server from there.

I created a server taking a part of the analysis_server (the protocol part), because I had to create an extension for VSCode and Dart-Code offered me to take a schema of the protocol that was used to communicate by IO to the analysis_server.

From there 3 projects were born.

Dart Polisher, the Formatter Server (yeah... generic name), and the VsCode Extension.


Dart Polisher is used as a library in the IO server (Formatter Server), which is compiled to an executable for each VsCode supported platform, and the VsCode extension starts one of these executables and communicates for formatting in the same way as the analysis_server does but only for code formatting.


Once I was done with that I wanted to have the ability to format code from vscode on the web, it was not possible to use the executables (the formatter server), so I developed a way to directly compile Dart Polisher to a node.js compatible version and use it directly in the vscode extension to make it web compatible, the downside is that the web version is ~8x times slower than the server version but it gets the job done.
The Formatter Server is still used on local installations of VsCode so formatting should be fast.

The important part is that if one wants something, make it.