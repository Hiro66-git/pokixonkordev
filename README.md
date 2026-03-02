Why Choose This Over Alternatives?
Feature	PokiXonkorDev	feroxbuster	gobuster	dirb
Language	Bash (portable)	Rust	Go	C
Installation	      Copy & run	Compile/download	Compile/download	apt install
Wildcard Detection	         ✅ Auto	✅ Auto	❌ Manual	❌ None
Recursion	                   ✅ Auto	✅ Auto	⚠️ Manual	✅ Auto
Platform Optimizations	     ✅ 4 versions	❌ Single binary	❌ Single binary	❌ Single binary
Purple Team Focused	         ✅ Built-in	❌ Red only	❌ Red only	❌ Red only
Custom Wordlist            	 ✅ 5000+ entries	❌ BYO	❌ BYO	⚠️ Limited
Proxy Support	               ✅ Full	✅ Full	✅ Limited	❌ None
Rate Limiting	               ✅ Configurable	✅ Configurable	❌ None	⚠️ Basic
Progress Bars                ✅ With pv	✅ Built-in	❌ None	⚠️ Basic
Open Source	                 ✅ MIT	✅ MIT	✅ Apache	✅ GPL
Customizable	               ✅ Edit Bash	⚠️ Rebuild	⚠️ Rebuild	⚠️ Recompile
Speed Comparison (10,000 paths, 20 threads):

feroxbuster: ~28s (Fastest - compiled Rust)
PokiXonkorDev + Parallel: ~32s  (Very fast - optimized Bash)
gobuster: ~38s
PokiXonkorDev (standard): ~45s
dirsearch: ~65s
dirb: ~180s  (Single-threaded)
