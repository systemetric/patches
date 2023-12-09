YEAR=2024
TEAM=$1
SALT=1

echo RoboCon${YEAR}-${TEAM}${SALT} | md5sum | head -c 8
echo