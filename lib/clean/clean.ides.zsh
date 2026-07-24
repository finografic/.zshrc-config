# ============================================================================ #
# NOTE: CLEAN IDES - Clear VSCode / VSCode Insiders / Cursor caches
# Usage: clean-ides  (alias: vsclean)
# CAUTION: Cursor — only safe caches (Cache, CachedData, Crashpad).
#          Chat and AI data are NOT cleared.
# ============================================================================ #

function clean-ides() {
	local APPLICATION_SUPPORT="$HOME/Library/Application Support"
	local CODE_PATH BASE_PATH IS_CURSOR=0
	local ide_choice response confirm

	typeset -A IDE_PATHS=(
		[code]="Code"
		[insiders]="Code - Insiders"
		[cursor]="Cursor"
	)

	# Step 1: Select IDE
	echo "\n${_grey}Select IDE to clean:${_0}"
	echo "${_y}1. VSCode Stable${_0}"
	echo "${_y}2. VSCode Insiders${_0}"
	echo "${_y}3. Cursor ${_grey}(safe only: Cache, CachedData, Crashpad - preserves Chat/AI)${_0}"
	echo "\n${_grey}Which IDE? ${_0}(1-3, Enter to cancel)\n"
	read -r ide_choice
	ide_choice=${ide_choice:-0}

	case $ide_choice in
	1) CODE_PATH="${IDE_PATHS[code]}" ;;
	2) CODE_PATH="${IDE_PATHS[insiders]}" ;;
	3) CODE_PATH="${IDE_PATHS[cursor]}" ;;
	*)
		echo "\n${_y}Operation aborted${_0}\n"
		return 0
		;;
	esac

	BASE_PATH="${APPLICATION_SUPPORT}/${CODE_PATH}"
	if [[ ! -d "$BASE_PATH" ]]; then
		echo "\n${_r}⚠️  ${CODE_PATH} not found at ${BASE_PATH}${_0}\n"
		return 1
	fi

	# Step 2: Select cache type (Cursor has restricted options)
	[[ "$CODE_PATH" == "Cursor" ]] && IS_CURSOR=1

	if [[ $IS_CURSOR -eq 1 ]]; then
		echo "\n${_grey}Cache options for Cursor ${_r}(Chat/AI data preserved):${_0}"
		echo "${_y}1. Cache files ${_grey}- CachedData, Cache${_0}"
		echo "${_y}2. Crash Reports ${_grey}- Crashpad${_0}"
		echo "${_y}A. ALL safe caches ${_grey}(Cache + CachedData + Crashpad)${_0}"
		echo "\n${_r}⚠️  Which? ${_0}(1-2, A for ALL, Enter to cancel)\n"
	else
		echo "\n${_grey}Cache options for ${CODE_PATH}:${_0}"
		echo "${_y}1. Code Storage ${_w}- User/globalStorage${_0}"
		echo "${_y}2. Cache files ${_w}- Cache, CachedData${_0}"
		echo "${_y}3. Crash Reports ${_w}- Crashpad${_0}"
		echo "${_y}4. Workbench State ${_w}- User/workspaceStorage${_0}"
		echo "${_y}A. ALL caches${_0}"
		echo "\n${_r}⚠️  Which? ${_0}(1-4, A for ALL, Enter to cancel)\n"
	fi

	read -r response
	response=${response:-N}

	if [[ $IS_CURSOR -eq 1 ]]; then
		case $response in
		1)
			rm -rf "$BASE_PATH/Cache"/* "$BASE_PATH/CachedData"/* 2>/dev/null
			echo "\n${_g}✅ Cursor cache cleared${_0}\n"
			;;
		2)
			rm -rf "$BASE_PATH/Crashpad"/* 2>/dev/null
			echo "\n${_g}✅ Cursor crash reports cleared${_0}\n"
			;;
		[Aa])
			rm -rf "$BASE_PATH/Cache"/* "$BASE_PATH/CachedData"/* "$BASE_PATH/Crashpad"/* 2>/dev/null
			echo "\n${_g}✅ All safe Cursor caches cleared${_0}\n"
			;;
		*)
			echo "\n${_y}Operation aborted${_0}\n"
			return 0
			;;
		esac
	else
		case $response in
		1)
			rm -rf "$BASE_PATH/User/globalStorage"/*
			echo "\n${_g}✅ Code Storage cleared${_0}\n"
			;;
		2)
			rm -rf "$BASE_PATH/Cache"/* "$BASE_PATH/CachedData"/*
			echo "\n${_g}✅ Cache files cleared${_0}\n"
			;;
		3)
			rm -rf "$BASE_PATH/Crashpad"/*
			echo "\n${_g}✅ Crash reports cleared${_0}\n"
			;;
		4)
			rm -rf "$BASE_PATH/User/workspaceStorage"/*
			echo "\n${_g}✅ Workbench state cleared${_0}\n"
			;;
		[Aa])
			echo "\n${_r}⚠️  Clear ALL caches? ${_0}(y/N)\n"
			read -r confirm
			if [[ "$confirm" =~ ^[Yy]$ ]]; then
				rm -rf "$BASE_PATH/User/globalStorage"/* "$BASE_PATH/Cache"/* "$BASE_PATH/CachedData"/* "$BASE_PATH/Crashpad"/* "$BASE_PATH/User/workspaceStorage"/*
				echo "\n${_g}✅ All caches cleared${_0}\n"
			else
				echo "\n${_y}Operation aborted${_0}\n"
			fi
			;;
		*)
			echo "\n${_y}Operation aborted${_0}\n"
			return 0
			;;
		esac
	fi

	echo "${_w}Restart ${CODE_PATH} after clearing caches.${_0}\n"
}
