# 網路程式作業三
### 執行方式:
1. make
2. sudo ./hw3 -r "pcap_filename" 

### 其他功能:

1. sudo ./hw3 -> 開啟瀏覽器

2. sudo ./hw3 filter(ex:tcp) 
        可過濾掉tcp以外的封包
3. sudo ./hw3 -r "pcap_filename" filter(ex:tcp)

### 資訊:

* https://wiki.wireshark.org/SampleCaptures  
可下載pcap檔案
    

### (1)程式流程
1. 設定各種協定的header
2. 抓取網路設備pcap_lookupdev()
3. 獲取設備ip與網路遮罩pcap_lookupnet()
4. 打開網絡接口pcap_open_live()
5. 設定過濾(filter) pcap_compile() + pcap_setfilter()
6. 捕獲多個封包pcap_loop()
7. 用callback()處理所獲取的封包

### (2)功能實作
callback()處理封包:

* 使用設定好的各種協定header(Ethernet、IP、TCP、UDP header)，計算IP header的位移量(offset)，獲取IP位址 以及 協定種類資訊(TCP or UDP)

* 根據該協定種類進行特定的header offset計算並獲得port號碼

* 運用time_t形態變數存取header的時間，用localtime()轉換成struct tm的形式，最後用strftime()轉換成string，印出time

### (3)資料結構
各種協定struct...
