YEAR=2025
TEAM=$1
SALT=Table

echo RoboCon${YEAR}-${TEAM}${SALT} | md5sum | head -c 8
echo

# YEAR | SALT
# 2024 | "1", "FILL_OUT", "FILL_IN"
# 2025 | "Table"

#nmcli -f SSID d wifi list | grep "RoboCon" | tr -d ' \n' | cat - <(echo "Table") | md5sum | head -c 8