#!/bin/sh

# Init server if not already initialized
if ! p4d -C1 -xD; then
    echo "[INFO] Initializing new P4D server..."
    p4d -C1 -xD "$P4NAME"
    p4d -C1 -Gc
fi

# Start server in background to perform setup
echo "[INFO] Starting Perforce server temporarily..."
p4d -C1 &

sleep 3

# Trust the fingerprint (auto)
echo "[INFO] Trusting the server fingerprint..."
echo yes | p4 trust

# Create superuser if it doesn't exist
if ! p4 users | grep -q "^fred "; then
    echo "[INFO] Creating superuser 'fred'..."
    echo -e "User: fred\nEmail: fred@localhost\nFullName: Fred Bast" | p4 user -i
    echo "[INFO] Setting password..."
    echo -e "SuperPass123\nSuperPass123" | p4 passwd fred
    echo "[INFO] Logging in..."
    echo "SuperPass123" | p4 login fred
fi

# Optional: enforce strong password policy
# p4 configure set security=3

# Kill temp background server (clean up)
kill $(pidof p4d)

# Final launch (foreground)
echo "[INFO] Launching Perforce server..."
exec p4d -C1
