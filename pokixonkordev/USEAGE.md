USAGE:
  pokixonkordev.sh -u <url> -w <wordlist> [options]

REQUIRED:
  -u, --url <url>          Target URL (http://example.com)
  -w, --wordlist <file>    Path to wordlist file

SCANNING OPTIONS:
  -t, --threads <num>      Parallel threads (default: 20)
  -x, --extensions <list>  Extensions to append (php,html,txt,jsp)
  -s, --status <codes>     Status codes to show (default: 200,301,302,401,403,405)
  -m, --method <method>    HTTP method (GET, POST, HEAD) (default: GET)
  -r, --recursive          Enable recursive directory scanning
  -d, --depth <num>        Maximum recursion depth (default: 1)
  --no-wildcard            Disable wildcard detection
  --no-progress            Disable progress bar

HTTP OPTIONS:
  -a, --user-agent <str>   Custom User-Agent string
  -H, --header <header>    Add custom header (can use multiple times)
  -c, --cookie <cookie>    Cookie string
  -p, --proxy <proxy>      Proxy URL (http://127.0.0.1:8080)
  --timeout <sec>          Request timeout (default: 10)
  --no-follow              Don't follow redirects

OUTPUT OPTIONS:
  -o, --output <file>      Save results to file
  -v, --verbose            Verbose output
  --json                   Output in JSON format

RATE LIMITING:
  --rate-limit <ms>        Delay between requests in milliseconds


External word lists recommended:

   # SecLists (industry standard)
   git clone https://github.com/danielmiessler/SecLists.git

   # Use with PokiXonkorDev
   ./pokixonkordev.sh -u http://target.com \
   -w SecLists/Discovery/Web-Content/raft-medium-directories.txt