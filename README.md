# leanix-utils
LeanIX Command Line Utils. Currently only contains a script to download a full Excel snapshot of a LeanIX workspace.

# Run it
    git clone https://github.com/ttosch/leanix-utils.git
Edit download_leanix_export.sh: Add your own API key, workspace ID, host name, possibly change the location of curl

Then run  

    ./download_leanix_export.sh

Or add it to a cron job. That's it :)
