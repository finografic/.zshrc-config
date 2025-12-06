#!/bin/zsh

# Docker Cleanup Script
# Safely removes unused Docker resources to free up disk space

# Source colors
source ~/.zshrc-config/lib/colors.zsh

# echo -e "\n${_m}🐳 Docker Cleanup Script${_0}\n"

# Function to show current usage
show_usage() {
    echo -e "${_g}📊 Current Docker Usage:${_0}"
    docker system df
    echo ""
}

# Function to show what will be removed
show_what_will_be_removed() {
    echo -e "${_y}🗑️  Items that will be removed:${_0}"

    # Show dangling images
    local dangling_images=$(docker images -f "dangling=true" -q)
    if [[ -n "$dangling_images" ]]; then
        echo -e "${_c}📦 Dangling Images:${_0}"
        docker images -f "dangling=true" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    else
        echo -e "${_c}📦 Dangling Images: None${_0}"
    fi

    # Show unused images
    local unused_images=$(docker images -f "dangling=false" -q)
    if [[ -n "$unused_images" ]]; then
        echo -e "${_c}📦 Unused Images:${_0}"
        docker images -f "dangling=false" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    else
        echo -e "${_c}📦 Unused Images: None${_0}"
    fi

    # Show build cache size
    local build_cache_size=$(docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}" | grep "Build Cache" | awk '{print $3}')
    echo -e "${_c}🏗️  Build Cache: $build_cache_size${_0}"

    echo ""
}

# Function to perform cleanup
perform_cleanup() {
    echo -e "${_m}🧹 Starting cleanup...${_0}\n"

    # Remove all stopped containers
    echo -e "${_y}🗑️  Removing stopped containers...${_0}"
    docker container prune -f

    # Remove all unused networks
    echo -e "${_y}🗑️  Removing unused networks...${_0}"
    docker network prune -f

    # Remove all unused images (including dangling)
    echo -e "${_y}🗑️  Removing unused images...${_0}"
    docker image prune -a -f

    # Remove all unused volumes
    echo -e "${_y}🗑️  Removing unused volumes...${_0}"
    docker volume prune -f

    # Remove all build cache
    echo -e "${_y}🗑️  Removing build cache...${_0}"
    docker builder prune -a -f

    echo -e "${_g}✅ Cleanup completed!${_0}\n"
}

# Function to show space saved
show_space_saved() {
    echo -e "${_g}💾 Space freed up:${_0}"
    docker system df
    echo ""
}

# Main docker-cleanup function
docker-cleanup() {
    case "${1:-help}" in
    "status"|"check")
        show_usage
        show_what_will_be_removed
        ;;
    "clean"|"cleanup")
        show_usage
        show_what_will_be_removed

        echo -e "${_y}⚠️  This will remove:${_0}"
        echo "  • All stopped containers"
        echo "  • All unused networks"
        echo "  • All unused images (including dangling)"
        echo "  • All unused volumes"
        echo "  • All build cache"
        echo ""

        echo -e "${_m}Are you sure you want to proceed? ${_grey}(y/N)${_0}"
        read -r response
        response=${response:-N}

        if [[ "$response" =~ ^[Yy]$ ]]; then
            perform_cleanup
            show_space_saved
        else
            echo -e "${_y}⚠️  Cleanup cancelled${_0}"
        fi
        ;;
    "force")
        show_usage
        perform_cleanup
        show_space_saved
        ;;
    "help"|"--help"|"-h"|*)
        echo -e "${_m}🐳 Docker Cleanup Script${_0}\n"
        echo "Usage: docker-cleanup [command]"
        echo ""
        echo -e "${_g}Commands:${_0}"
        echo "  status/check - Show current usage and what will be removed"
        echo "  clean/cleanup - Interactive cleanup (asks for confirmation)"
        echo "  force        - Force cleanup without confirmation"
        echo "  help         - Show this help"
        echo ""
        echo -e "${_c}Examples:${_0}"
        echo "  docker-cleanup status    # Check what can be cleaned"
        echo "  docker-cleanup clean     # Safe cleanup with confirmation"
        echo "  docker-cleanup force     # Force cleanup"
        echo ""
        ;;
    esac
}

# Command line interface (only runs when script is executed directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    docker-cleanup "$@"
fi
