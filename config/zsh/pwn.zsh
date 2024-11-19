run-docker-env() {
    # 检查必需的命令是否存在
    for cmd in docker curl jq; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "错误: '$cmd' 未安装。请安装 '$cmd' 并重试。"
            return 1
        fi
    done

    # 检查 Docker 是否安装
    if ! command -v docker &> /dev/null; then
        echo "错误: Docker 未安装。请安装 Docker 并确保服务正在运行。"
        return 1
    fi

    # 检查 Docker 守护进程是否运行
    if ! docker info &> /dev/null; then
        echo "错误: Docker 守护进程未运行。请启动 Docker 服务。"
        return 1
    fi

    # 设置默认仓库，可通过第一个参数自定义
    local repository="${1:-ra4ing/pwn}"
    local image
    local tags
    local page=1
    local per_page=100  # 每页获取100个标签
    local total_pages=1

    echo "正在获取仓库 '$repository' 的可用标签..."

    tags=()
    while (( page <= total_pages )); do
        response=$(curl -s "https://hub.docker.com/v2/repositories/$repository/tags/?page=$page&page_size=$per_page")

        if [[ -z "$response" ]]; then
            echo "错误: 无法获取仓库标签。请检查网络连接或仓库名称是否正确。"
            return 1
        fi

        # 提取标签名称
        page_tags=$(echo "$response" | jq -r '.results[].name')
        if [[ -z "$page_tags" ]]; then
            break
        fi

        # 添加到 tags 数组
        while IFS= read -r tag; do
            tags+=("$tag")
        done <<< "$page_tags"

        # 计算总页数
        total_count=$(echo "$response" | jq -r '.count')
        total_pages=$(( (total_count + per_page - 1) / per_page ))
        ((page++))
    done

    if (( ${#tags[@]} == 0 )); then
        echo "错误: 未找到任何标签。请检查仓库名称是否正确。"
        return 1
    fi

    # 对标签进行排序（按名字字母顺序）
    tags_sorted=($(printf "%s\n" "${tags[@]}" | sort))
    tags=("${tags_sorted[@]}")

    # 列出标签
    echo "可用标签 (${#tags[@]} 个):"
    for i in {1..${#tags[@]}}; do
        printf "%3d) %s\n" "$i" "${tags[$i]}"
    done

    # 提示用户选择标签
    while true; do
        echo -n "请选择一个标签（输入序号，或按 Enter 使用最新标签，输入 'q' 退出）： "
        read -r tag_choice

        if [[ -z "$tag_choice" ]]; then
            # 获取数组长度
            local len=${#tags[@]}
            # 获取最后一个元素（最新标签）
            selected_tag="${tags[$len]}"
            echo "使用最新标签: $selected_tag"
            break
        elif [[ "$tag_choice" =~ ^[Qq]$ ]]; then
            echo "已取消操作。"
            return 0
        elif [[ "$tag_choice" =~ ^[0-9]+$ ]] && (( tag_choice >= 1 )) && (( tag_choice <= ${#tags[@]} )); then
            selected_tag="${tags[tag_choice]}"
            echo "选择的标签: $selected_tag"
            break
        else
            echo "无效的选择，请输入有效的序号、回车或 'q'。"
        fi
    done

    image="$repository:$selected_tag"
    echo "准备启动 Docker 容器，镜像: $image"

    # 检查本地是否存在该镜像
    if ! docker image inspect "$image" &> /dev/null; then
        echo "本地未找到镜像 '$image'。正在从 Docker Hub 拉取..."
        if ! docker pull "$image"; then
            echo "错误: 拉取镜像 '$image' 失败。"
            return 1
        fi
    else
        echo "已存在本地镜像 '$image'。"
    fi

    # 设置挂载路径，处理路径中的空格和特殊字符
    local current_dir
    current_dir=$(pwd)
    # 在 zsh 中，不需要像 bash 那样转义路径中的空格，直接使用引号包裹即可

    # 确认运行参数
    echo "即将运行 Docker 容器。参数如下："
    echo "  - 交互模式 (-it)"
    echo "  - 容器结束后自动删除 (--rm)"
    echo "  - 挂载当前目录到容器内路径: \"$current_dir:/home/ra4ing/hacker\""
    echo "  - 以特权模式运行 (--privileged)"
    echo "  - 镜像: $image"

    echo "正在启动容器..."
    docker run -it --rm -v "$current_dir:/home/ra4ing/hacker" --privileged "$image"
}

