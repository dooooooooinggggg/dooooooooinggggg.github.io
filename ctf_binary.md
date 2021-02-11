# CTFなどでバイナリ解析する際のツール群の使い方

※随時更新

## Tools

### objdump

- `-d`

> objfile の機械語命令に対応するアセンブラのニーモニックを表示する。このオプションは、命令を含むと思われるセクションのみを逆アセンブルする。

- `-D`

> -d と似ているが、命令を含むと思われるセクションだけでなく、全てのセクションを逆アセンブルする。

```sh
objdump -d binary
objdump -D binary
```

### readelf

各セクションのファイル中のオフセット等を表示。

<!-- TODO: 補足 -->

```sh
readelf -S binary
```

### peda(gdb)

GDBのプラグイン。
コマンドが追加されたりしている。

### Pwngdb

heapinfoコマンドが追加されている。これにより、実行時、ヒープの情報を確認できる。

### gdb

- `run`
  - プログラムの実行を開始
- `start`
  - プログラムの実行を開始、main関数で停止
- `continue`
  - 停止したプログラムの実行を再開
- `disass func`
  - 指定するfuncを逆アセンブル。省略すると今いる関数を逆アセンブル。
- `break *0xabcdef`
  - ブレークポイントを設定。`*main+12`のように計算式での指定も可能
- `until *0xabcdef`
  - breakの一度きりバージョン。二度目の実行の際には停止しない。
- `stepi` or `si`
  - 1ステップ実行する
  - 連続実行のときは何も入力しないでEnter
- `nexti` or `ni`
  - 1ステップ実行する。しかし、`call`で関数を呼び出す場合、関数の中身は実行する。(callの次のアドレスの命令で停止)
- `x/16xg 0xabcdef`
  - 最初の`x`はexamine
  - アドレス`0xabcdef`から、8バイトの値を16個表示
  - 連続実行のときは何も入力しないでEnter
  - 詳しくは後述
- `set $rax=0xabcdef`
  - `$rax`に`0xabcdef`を代入
  - `set *0x1234=0xabcd`のようにメモリを書き換えることも可能
  - デフォルトでは8バイト
    - バイト単位で書き換えるときは、`set *(char*)0x1234=0x12`とする
- `print $rax+0x10`
  - 計算結果などを確認するときに使う


#### x

`x/16xg 0xabcdef`に関して。

|     |         |
| --- | ------- |
| g   | 8 Bytes |
| w   | 4 Bytes |
| h   | 2 Bytes |
| b   | 1 Byte  |

`16`の後の`x`は符号なし16進数。
`u`とすると符号なし10進数。

アドレスの値を`$rax`のようにして、レジスタの値を参照することもできる。

### checksec

実行ファイルのセキュリティ機構が有効かどうかを確認する。

```sh
~/checksec.sh/checksec --file=path/to/file
```

#### RELRO

- `RElocation Read Only`
- libcなどの共有ライブラリ中のシンボルのアドレスは実行されるまでわからない
  - →実行開始時や実行中に、`GOT`という領域にこれらのアドレスがかかる。
  - GOTが読み込みのみかどうかを表示

|               |                                                                                                                                               |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| No RELRO      | 書き込み可能。GOTを書き換えて攻撃可能                                                                                                         |
| Partial RELRO | `__libc_start_main`などの限られた関数のアドレスのみ書き換え不可能。`printf()`などの関数のアドレスは最初の読み込み時に解決されるため、攻撃可能 |
| Full RELRO    | すべて実行時に解決されるため、書き換え不可能                                                                                                  |

#### Stack Canary

スタックオーバーフローに対する緩和策。

Canary foundのときは、この対策が有効になっているため、それを用いた攻撃が困難。

#### NX

No eXecute

- enableなら、スタックが実行可能
- disabledならば実行不可能

disabledになっているときは、意図的であることが多い

#### PIE

共有ライブラリや、ヒープ、スタックは、実行するたびにランダムにそのアドレスが変わる(`ASLR`)

実行ファイルのアドレスもランダム化するのが`PIE`

|                 |                                                       |
| --------------- | ----------------------------------------------------- |
| No PIE          | PIEが無効。実行ファイルは特定のアドレスに読み出される |
| PIE enabled     | PIEが有効。攻撃実施前にわかっているアドレスはない     |
| DSO             | Dynamic Shared Object                                 |
| Not an ELF file | ELFファイルじゃない                                   |

### socat

<!-- TODO: socatの説明 -->

バイトストリームをつなぐコマンド。→問題のプログラムの標準入出力をTCP通信に変換できる。

### OneGadget

libcには、そこに飛ばすだけでシェルを起動できる`One-gadget RCE(Remote Code Execution)`というアドレスがある。
`OneGadet`は、そのアドレスを探してくれるツール。

```sh
one_gadget libc-2.31.so
# 0xe6c7e execve("/bin/sh", r15, r12)
# constraints:
#   [r15] == NULL || r15 == NULL
#   [r12] == NULL || r12 == NULL

# 0xe6c81 execve("/bin/sh", r15, rdx)
# constraints:
#   [r15] == NULL || r15 == NULL
#   [rdx] == NULL || rdx == NULL

# 0xe6c84 execve("/bin/sh", rsi, rdx)
# constraints:
#   [rsi] == NULL || rsi == NULL
#   [rdx] == NULL || rdx == NULL

one_gadget libc-2.31.so -l 1
# 0xe6c7e execve("/bin/sh", r15, r12)
# constraints:
#   [r15] == NULL || r15 == NULL
#   [r12] == NULL || r12 == NULL

# 0xe6c81 execve("/bin/sh", r15, rdx)
# constraints:
#   [r15] == NULL || r15 == NULL
#   [rdx] == NULL || rdx == NULL

# 0xe6c84 execve("/bin/sh", rsi, rdx)
# constraints:
#   [rsi] == NULL || rsi == NULL
#   [rdx] == NULL || rdx == NULL

# 0xe6e73 execve("/bin/sh", r10, r12)
# constraints:
#   address rbp-0x78 is writable
#   [r10] == NULL || r10 == NULL
#   [r12] == NULL || r12 == NULL

# 0xe6e76 execve("/bin/sh", r10, rdx)
# constraints:
#   address rbp-0x78 is writable
#   [r10] == NULL || r10 == NULL
#   [rdx] == NULL || rdx == NULL
```

## lea命令

メモリのアドレス自体をディスティネーションに書き込む。

```asm
lea rax, [rbp-0x110]
```

という命令で、rbpが`0x7ffffffedca0`の場合、raxには、`0x7ffffffedb90`という値が入る。
mvの場合は、`0x7ffffffedb90`に格納されている値がraxに書き込まれる。

## x86_64における関数の引数

1. `rdi`
2. `rsi`
3. `rdx`
4. `rcx`
5. `r8`
6. `r9`

## install tools

```sh
# pwntools
pip install pwntools

# contains objdump etc...
sudo apt install binutils 

# peda
git clone https://github.com/longld/peda ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit

# pwngdb
git clone https://github.com/scwuaptx/Pwngdb ~/Pwngdb
cat ~/Pwngdb/.gdbinit >> ~/.gdbinit

# checksec
git clone https://github.com/slimm609/checksec.sh ~/checksec.sh

# socat
sudo apt install socat

# OneGadet
gem install one_gadget
```


## 参考文献

- [解題pwnable　セキュリティコンテストに挑戦しよう！ | 電子書籍とプリントオンデマンド（POD） | NextPublishing（ネクストパブリッシング）](https://nextpublishing.jp/book/12609.html)

- [Man page of objdump](https://linuxjm.osdn.jp/html/GNU_binutils/man1/objdump.1.html)
- [readelf(1) manページ<](https://nxmnpg.lemoda.net/ja/1/readelf)
- [https://linux.die.net/man/1/socat](socat(1): Multipurpose relay - Linux man page)
