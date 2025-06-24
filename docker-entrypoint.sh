#!/bin/sh

# Init server if not already initialized
if ! p4d -C1 -xD; then
    echo "[INFO] Initializing new P4D server..."
    p4d -C1 -xD "$P4_NAME"
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
if ! p4 users | grep -q "^$P4_USER "; then
    echo "[INFO] Creating superuser '$P4_USER'..."
    echo -e "User: $P4_USER\nEmail: $P4_EMAIL\nFullName: $P4_FULL_NAME" | p4 user -i
    echo "[INFO] Setting password..."
    echo -e "$P4_PASS\n$P4_PASS" | p4 passwd "$P4_USER"
    echo "[INFO] Logging in..."
    echo "$P4_PASS" | p4 login "$P4_USER"
fi

# Optional: enforce strong password policy
# p4 configure set security=3

# Kill temp background server (clean up)
kill $(pidof p4d)

# Final launch (foreground)
echo "[INFO] Launching Perforce server..."
exec p4d -C1
