#!/bin/bash
bold="\033[1m"
ncol="\033[0m"

# Variabel warna
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'

echo -e "${blue}
████████╗██╗██████╗░████████╗░█████╗░██████╗░
╚══██╔══╝██║██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗
░░░██║░░░██║██║░░██║░░░██║░░░██║░░██║██║░░██║
░░░██║░░░██║██║░░██║░░░██║░░░██║░░██║██║░░██║
░░░██║░░░██║██████╔╝░░░██║░░░╚█████╔╝██████╔╝
░░░╚═╝░░░╚═╝╚═════╝░░░░╚═╝░░░░╚════╝░╚═════╝░${ncol}"
echo "╔═══════════════════════════════════════════╗ "

echo -e "${yellow}[•]CREATED by EXPLOIT INDEPENDENT${ncol}"
echo -e "${yellow}[•]CREATED by MR.4REX 405${ncol}"
echo "╚═══════════════════════════════════════════╝"
get_username() {
read -p '
┌─[USERNAME]─[TARGET]
└──$  ' username
    username="${username//@/}"  # Menghapus simbol @ jika ada
}
echo

# Fungsi untuk mendapatkan keterangan laporan dari input
get_report_description() {
    read -p '
┌─[MASUKAN]─[ALASAN]
└──$   ' report_description
}
echo
# Fungsi untuk menghasilkan URL laporan
generate_report_url() {
    local user_id=$1
    local sec_uid=$2
    local base_url='https://www.tiktok.com/aweme/v2/aweme/feedback/?'
    
    echo "${base_url}aid=1988&app_language=en&app_name=tiktok_web&nickname=${username}&object_id=${user_id}&secUid=${sec_uid}&report_type=user&reporter_id=${user_id}&description=${report_description}"
}

# Fungsi untuk mengirim laporan
send_report() {
    local report_url=$1
    local proxy=$2

    # Mengirim permintaan laporan menggunakan curl
    response=$(curl -s -x "$proxy" -X POST "$report_url")
    echo -e "${green}REPORT AKUN  $username MENGGUNAKAN PROXY SUKSES : $proxy"
}
echo
# Fungsi untuk mendapatkan daftar proxy dari file txt
get_proxies() {
    echo "Mengambil daftar proxy dari file..."
    if [[ -f "proxies.txt" ]]; then
        mapfile -t proxies < "proxies.txt"
    else
        echo "File proxies.txt tidak ditemukan."
        exit 1
    fi
}

# Fungsi utama
main() {
    get_username
    get_report_description
    get_proxies
    
    # Mendapatkan ID pengguna dan secUid dari TikTok
    user_info=$(curl -s "https://www.tiktok.com/@${username}")
    user_id=$(echo "$user_info" | grep -oP '"id":"\K[^"]+')
    sec_uid=$(echo "$user_info" | grep -oP '"secUid":"\K[^"]+')
    
    if [[ -z "$user_id" || -z "$sec_uid" ]]; then
        echo "Error: Tidak dapat menemukan informasi pengguna."
        exit 1
    fi

    report_url=$(generate_report_url "$user_id" "$sec_uid")

    while true; do
        for proxy in "${proxies[@]}"; do
            send_report "$report_url" "$proxy" &  # Jalankan secara paralel
            # Batasi jumlah proses yang berjalan
            if [[ $(jobs -r -p | wc -l) -ge 5 ]]; then
                wait -n  # Tunggu salah satu proses selesai
            fi
        done
        wait  # Tunggu semua proses selesai sebelum melanjutkan

        # Tunggu 30 detik sebelum mengulang
        sleep 1
    done
}

main
