echo $_grey
echo "Cleaning Downloads..."
echo $_0

# NPM CACHE CLEAN (security)
npm cache clean --force

# NOTE: Optional npm checks

# See where npm keeps cache
# $ npm config get cache
# Prune bad entries without a full wipe (npm 5+)
# $ npm cache verify

# PNPM STORE PRUNE (security)
# pnpm store prune
