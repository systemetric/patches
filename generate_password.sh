YEAR=2025
TEAM=$1
SALT=Table

echo RoboCon${YEAR}-${TEAM}${SALT} | md5sum | head -c 8
echo
