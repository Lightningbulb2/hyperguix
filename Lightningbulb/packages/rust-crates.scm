;;; GENERATED FILE -- do not edit by hand.
;;; Regenerate with the scripts in contrib/ when the upstream lockfiles change.

;;; Crate sources for the Rust applications in this channel, one origin per
;;; entry in each upstream Cargo.lock.  The hashes are the Cargo.lock
;;; checksums (sha256 of the .crate file) re-encoded in nix-base32, so they
;;; can be checked against the lockfile without downloading anything.

(define-module (Lightningbulb packages rust-crates)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system cargo)
  #:export (scrcpy-gui-cargo-inputs
            faforever-client-cargo-inputs))

(define (crate name version hash)
  (origin
    (method url-fetch)
    (uri (crate-uri name version))
    (file-name (string-append "rust-" name "-" version ".tar.gz"))
    (sha256 (base32 hash))))

(define rust-Inflector-0.11.4
  (crate "Inflector" "0.11.4" "1lqmcni21ifzyq41fhz6k1j2b23cmsx469s4g4sf01l78miqqhzy"))
(define rust-adler2-2.0.1
  (crate "adler2" "2.0.1" "1ymy18s9hs7ya1pjc9864l30wk8p2qfqdi7mhhcc5nfakxbij09j"))
(define rust-aes-0.8.4
  (crate "aes" "0.8.4" "1853796anlwp4kqim0s6wm1srl4ib621nm0cl2h3c8klsjkgfsdi"))
(define rust-aes-0.9.0
  (crate "aes" "0.9.0" "1y5fmmr0ifj7cx5ck04vsw1r51wps1qg6h313i1w0i5n6akjkgb6"))
(define rust-aes-0.9.3
  (crate "aes" "0.9.3" "0cpascsyy7mzjmx3q3q0fjz8aqyhcf0slj49dpfc6f4fwxngkw1m"))
(define rust-aho-corasick-1.1.4
  (crate "aho-corasick" "1.1.4" "00a32wb2h07im3skkikc495jvncf62jl6s96vwc7bhi70h9imlyx"))
(define rust-alloc-no-stdlib-2.0.4
  (crate "alloc-no-stdlib" "2.0.4" "1cy6r2sfv5y5cigv86vms7n5nlwhx1rbyxwcraqnmm1rxiib2yyc"))
(define rust-alloc-stdlib-0.2.2
  (crate "alloc-stdlib" "0.2.2" "1kkfbld20ab4165p29v172h8g0wvq8i06z8vnng14whw0isq5ywl"))
(define rust-alloc-stdlib-0.2.4
  (crate "alloc-stdlib" "0.2.4" "159iyap790nflvdhl1gbkxp9l5w4x7qp5ybg01wx490jx4cs0xhf"))
(define rust-android_system_properties-0.1.5
  (crate "android_system_properties" "0.1.5" "04b3wrz12837j7mdczqd95b732gw5q7q66cv4yn4646lvccp57l1"))
(define rust-anyhow-1.0.102
  (crate "anyhow" "1.0.102" "0b447dra1v12z474c6z4jmicdmc5yxz5bakympdnij44ckw2s83z"))
(define rust-anyhow-1.0.104
  (crate "anyhow" "1.0.104" "0w34jjcm02p5g9kvsjr1dvpw0zs2fi7igi6nr414fkm5gz85w2ik"))
(define rust-async-broadcast-0.7.2
  (crate "async-broadcast" "0.7.2" "0ckmqcwyqwbl2cijk1y4r0vy60i89gqc86ijrxzz5f2m4yjqfnj3"))
(define rust-async-channel-2.5.0
  (crate "async-channel" "2.5.0" "1ljq24ig8lgs2555myrrjighycpx2mbjgrm3q7lpa6rdsmnxjklj"))
(define rust-async-executor-1.14.0
  (crate "async-executor" "1.14.0" "0al1rmxjy7p7r6h50z698q5lwssqs5a2vzmqbazm1z2sv1rgjsy9"))
(define rust-async-io-2.6.0
  (crate "async-io" "2.6.0" "1z16s18bm4jxlmp6rif38mvn55442yd3wjvdfhvx4hkgxf7qlss5"))
(define rust-async-lock-3.4.2
  (crate "async-lock" "3.4.2" "04c3xrrdrfrvh9v0ajxrangpy38qi76qq268zslphnxxjqjpy3r9"))
(define rust-async-process-2.5.0
  (crate "async-process" "2.5.0" "0xfswxmng6835hjlfhv7k0jrfp7czqxpfj6y2s5dsp05q0g94l7w"))
(define rust-async-recursion-1.1.1
  (crate "async-recursion" "1.1.1" "04ac4zh8qz2xjc79lmfi4jlqj5f92xjvfaqvbzwkizyqd4pl4hrv"))
(define rust-async-signal-0.2.14
  (crate "async-signal" "0.2.14" "11dlpb15la279r5cazppy18gbk2xzzl60ahzl19m1kr0l2psmdaj"))
(define rust-async-task-4.7.1
  (crate "async-task" "4.7.1" "1pp3avr4ri2nbh7s6y9ws0397nkx1zymmcr14sq761ljarh3axcb"))
(define rust-async-trait-0.1.92
  (crate "async-trait" "0.1.92" "0rqn5iga1hlv2lm8xzav1zhar46jb4dvx89i6kfv93kb53maxxl2"))
(define rust-atk-0.18.2
  (crate "atk" "0.18.2" "0jw2n5xln62px4dh0hxdzbkbfraznkjakwznwhxrjbh72c9646r4"))
(define rust-atk-sys-0.18.2
  (crate "atk-sys" "0.18.2" "11nh2h3g7s772wb6lmjdsjbwi8rf9i11gvyyp8mpv9qc9dl8pr65"))
(define rust-atomic-waker-1.1.2
  (crate "atomic-waker" "1.1.2" "1h5av1lw56m0jf0fd3bchxq8a30xv0b4wv8s4zkp4s0i7mfvs18m"))
(define rust-autocfg-1.5.0
  (crate "autocfg" "1.5.0" "1s77f98id9l4af4alklmzq46f21c980v13z2r1pcxx6bqgw0d1n0"))
(define rust-autocfg-1.5.1
  (crate "autocfg" "1.5.1" "0lqasy5i30flcgih1b50kvsk6z32g09r1q4ql7q81pj6228jy0zj"))
(define rust-base64-0.21.7
  (crate "base64" "0.21.7" "0rw52yvsk75kar9wgqfwgb414kvil1gn7mqkrhn9zf1537mpsacx"))
(define rust-base64-0.22.1
  (crate "base64" "0.22.1" "1imqzgh7bxcikp5vx3shqvw9j09g9ly0xr0jma0q66i52r7jbcvj"))
(define rust-bit-set-0.8.0
  (crate "bit-set" "0.8.0" "18riaa10s6n59n39vix0cr7l2dgwdhcpbcm97x1xbyfp1q47x008"))
(define rust-bit-vec-0.8.0
  (crate "bit-vec" "0.8.0" "1xxa1s2cj291r7k1whbxq840jxvmdsq9xgh7bvrxl46m80fllxjy"))
(define rust-bitflags-1.3.2
  (crate "bitflags" "1.3.2" "12ki6w8gn1ldq7yz9y680llwk5gmrhrzszaa17g1sbrw2r2qvwxy"))
(define rust-bitflags-2.11.1
  (crate "bitflags" "2.11.1" "1cvqijg3rvwgis20a66vfdxannjsxfy5fgjqkaq3l13gyfcj4lf4"))
(define rust-bitflags-2.13.0
  (crate "bitflags" "2.13.0" "1y239gpvl061rfvav7jds8mjs42kmwi39is7yx5d1qw3hvp8nf5l"))
(define rust-block-buffer-0.10.4
  (crate "block-buffer" "0.10.4" "0w9sa2ypmrsqqvc20nhwr75wbb5cjr4kkyhpjm1z1lv2kdicfy1h"))
(define rust-block-buffer-0.12.0
  (crate "block-buffer" "0.12.0" "1glh8w49a7cj0wlkalyn9j605jzf2ss0lg8dqq5xh8cr2q451lyd"))
(define rust-block-buffer-0.12.1
  (crate "block-buffer" "0.12.1" "1ak0cvmxz3yifqmzv6aba9606brsz7d5g3piv5xdcvjsx7dwgxnj"))
(define rust-block-padding-0.3.3
  (crate "block-padding" "0.3.3" "14wdad0r1qk5gmszxqd8cky6vx8qg7c153jv981mixzrpzmlz2d8"))
(define rust-block2-0.6.2
  (crate "block2" "0.6.2" "1xcfllzx6c3jc554nmb5qy6xmlkl6l6j5ib4wd11800n0n3rvsyd"))
(define rust-blocking-1.6.2
  (crate "blocking" "1.6.2" "08bz3f9agqlp3102snkvsll6wc9ag7x5m1xy45ak2rv9pq18sgz8"))
(define rust-brotli-8.0.2
  (crate "brotli" "8.0.2" "0q25r00z3gm5wzvv4vfxvlx5zjb8i4jwyznrvdcp7abs7ihbkn2b"))
(define rust-brotli-8.0.4
  (crate "brotli" "8.0.4" "1cv6f4hdivllg34slvbwy645p1zidbxwpp1vh8jiwyha0sn1mjaw"))
(define rust-brotli-decompressor-5.0.0
  (crate "brotli-decompressor" "5.0.0" "00yyswj1rj20ma4wr4wcci4r9ywlgvxa87nqsv5rik5y588vhjw7"))
(define rust-brotli-decompressor-5.0.3
  (crate "brotli-decompressor" "5.0.3" "10rm4pyqnznh192nzsjl4dh6bjgzglsadcl676y6f6gy2nnaqcis"))
(define rust-bs58-0.5.1
  (crate "bs58" "0.5.1" "1x3v51n5n2s3l0rgrsn142akdf331n2qsa75pscw71fi848vm25z"))
(define rust-bumpalo-3.20.2
  (crate "bumpalo" "3.20.2" "1jrgxlff76k9glam0akhwpil2fr1w32gbjdf5hpipc7ld2c7h82x"))
(define rust-bumpalo-3.20.3
  (crate "bumpalo" "3.20.3" "0jc6va3nwcqikm7chnpdv1s87my3gs2j7g1sc7g3k91brg3arxbj"))
(define rust-bytemuck-1.25.0
  (crate "bytemuck" "1.25.0" "1v1z32igg9zq49phb3fra0ax5r2inf3aw473vldnm886sx5vdvy8"))
(define rust-byteorder-1.5.0
  (crate "byteorder" "1.5.0" "0jzncxyf404mwqdbspihyzpkndfgda450l0893pz5xj685cg5l0z"))
(define rust-bytes-1.11.1
  (crate "bytes" "1.11.1" "0czwlhbq8z29wq0ia87yass2mzy1y0jcasjb8ghriiybnwrqfx0y"))
(define rust-bzip2-0.6.1
  (crate "bzip2" "0.6.1" "0v1lgjxy944fdvsl97wmqs7f288crv7xddalk6y82jpk4jn3z9gk"))
(define rust-cairo-rs-0.18.5
  (crate "cairo-rs" "0.18.5" "1qjfkcq3mrh3p01nnn71dy3kn99g21xx3j8xcdvzn8ll2pq6x8lc"))
(define rust-cairo-sys-rs-0.18.2
  (crate "cairo-sys-rs" "0.18.2" "0lfsxl7ylw3phbnwmz3k58j1gnqi6kc2hdc7g3bb7f4hwnl9yp38"))
(define rust-camino-1.2.2
  (crate "camino" "1.2.2" "0j0ayqfbbl8bxg0795ssk1hzkjix3dvl2kk63hdgzf9cd5nscag6"))
(define rust-cargo-platform-0.1.9
  (crate "cargo-platform" "0.1.9" "1sinpmqjdk3q9llbmxr0h0nyvqrif1r5qs34l000z73b024z2np3"))
(define rust-cargo_metadata-0.19.2
  (crate "cargo_metadata" "0.19.2" "1fkr8jp6vhva4kc3rhx13yrnl8g3zch463j20vbwa9scxlabcpnx"))
(define rust-cargo_toml-0.22.3
  (crate "cargo_toml" "0.22.3" "0xvbl0nbi84hvhxiy0brmfvcn63bmj88799fjzsc204w5mcpqjrp"))
(define rust-cbc-0.1.2
  (crate "cbc" "0.1.2" "19l9y9ccv1ffg6876hshd123f2f8v7zbkc4nkckqycxf8fajmd96"))
(define rust-cc-1.2.61
  (crate "cc" "1.2.61" "0vawvnrrsmi8dygavq3wx085cmlp10sp3fhld5842rlqkqsr0vfi"))
(define rust-cc-1.2.64
  (crate "cc" "1.2.64" "07shcd8faxw7csz13m3cg2mj6i8z07pqs960k181pscbjpyqgn6s"))
(define rust-cesu8-1.1.0
  (crate "cesu8" "1.1.0" "0g6q58wa7khxrxcxgnqyi9s1z2cjywwwd3hzr5c55wskhx6s0hvd"))
(define rust-cfb-0.7.3
  (crate "cfb" "0.7.3" "03y6p3dlm7gfds19bq4ba971za16rjbn7q2v0vqcri52l2kjv3yk"))
(define rust-cfg-expr-0.15.8
  (crate "cfg-expr" "0.15.8" "00lgf717pmf5qd2qsxxzs815v6baqg38d6m5i6wlh235p14asryh"))
(define rust-cfg-if-1.0.4
  (crate "cfg-if" "1.0.4" "008q28ajc546z5p2hcwdnckmg0hia7rnx52fni04bwqkzyrghc4k"))
(define rust-cfg_aliases-0.2.1
  (crate "cfg_aliases" "0.2.1" "092pxdc1dbgjb6qvh83gk56rkic2n2ybm4yvy76cgynmzi3zwfk1"))
(define rust-chrono-0.4.44
  (crate "chrono" "0.4.44" "1c64mk9a235271j5g3v4zrzqqmd43vp9vki7vqfllpqf5rd0fwy6"))
(define rust-chrono-0.4.45
  (crate "chrono" "0.4.45" "09rkcgk6is2sdhqs9142zv8xqnj8ryx8m9hknllqwyv9wxi9x9qs"))
(define rust-cipher-0.4.4
  (crate "cipher" "0.4.4" "1b9x9agg67xq5nq879z66ni4l08m6m3hqcshk37d4is4ysd3ngvp"))
(define rust-cipher-0.5.1
  (crate "cipher" "0.5.1" "1skqij7dx6glllvr3x59w5nzv07zaqh7j4zb7828k8hvzqkq4kg3"))
(define rust-cipher-0.5.2
  (crate "cipher" "0.5.2" "0v7sic43nmz4rgql62wmxq0z63s80gnmd0w5q1vlhw6djcn2mkz8"))
(define rust-cmov-0.5.3
  (crate "cmov" "0.5.3" "0ipp2fzpcz2z9l4ywks98bd1viwpw81lfd5pdj3sdi0z04ys921z"))
(define rust-cmov-0.5.4
  (crate "cmov" "0.5.4" "0yh22sqdvcdrfbhvnja4kaq5dyklpb4s70w5r6rplfdw4jna17hc"))
(define rust-combine-4.6.7
  (crate "combine" "4.6.7" "1z8rh8wp59gf8k23ar010phgs0wgf5i8cx4fg01gwcnzfn5k0nms"))
(define rust-concurrent-queue-2.5.0
  (crate "concurrent-queue" "2.5.0" "0wrr3mzq2ijdkxwndhf79k952cp4zkz35ray8hvsxl96xrx1k82c"))
(define rust-const-oid-0.10.2
  (crate "const-oid" "0.10.2" "0p7m286mp8aai4sa72g7ji6qm0d4ns8wg4i4b2hj9p9615zm3vx6"))
(define rust-constant_time_eq-0.4.2
  (crate "constant_time_eq" "0.4.2" "16zamq60dq80k3rqlzh9j9cpjhishmh924lnwbplgrnmkkvfylix"))
(define rust-constant_time_eq-0.6.1
  (crate "constant_time_eq" "0.6.1" "1nbi63dr76nlkx8z0d409rkarl20x6239rykrjix0rfzfnqzxdly"))
(define rust-convert_case-0.4.0
  (crate "convert_case" "0.4.0" "03jaf1wrsyqzcaah9jf8l1iznvdw5mlsca2qghhzr9w27sddaib2"))
(define rust-cookie-0.18.1
  (crate "cookie" "0.18.1" "0iy749flficrlvgr3hjmf3igr738lk81n5akzf4ym4cs6cxg7pjd"))
(define rust-core-foundation-0.10.1
  (crate "core-foundation" "0.10.1" "1xjns6dqf36rni2x9f47b65grxwdm20kwdg9lhmzdrrkwadcv9mj"))
(define rust-core-foundation-0.9.4
  (crate "core-foundation" "0.9.4" "13zvbbj07yk3b61b8fhwfzhy35535a583irf23vlcg59j7h9bqci"))
(define rust-core-foundation-sys-0.8.7
  (crate "core-foundation-sys" "0.8.7" "12w8j73lazxmr1z0h98hf3z623kl8ms7g07jch7n4p8f9nwlhdkp"))
(define rust-core-graphics-0.25.0
  (crate "core-graphics" "0.25.0" "15rv1iyx5g9sy36pjf1ib6km93n8dksn2p9crx14h6f30brssjq6"))
(define rust-core-graphics-types-0.2.0
  (crate "core-graphics-types" "0.2.0" "1sqka1rz84lr3p69i1s6lggnpnznmrw4ngc5q76w9xhky80s2i1x"))
(define rust-cpubits-0.1.1
  (crate "cpubits" "0.1.1" "1bh6rvanxm00myf1rmnh44hq2jdxn69971c92s4klz0k76f5zf0m"))
(define rust-cpufeatures-0.2.17
  (crate "cpufeatures" "0.2.17" "10023dnnaghhdl70xcds12fsx2b966sxbxjq5sxs49mvxqw5ivar"))
(define rust-cpufeatures-0.3.0
  (crate "cpufeatures" "0.3.0" "00fjhygsqmh4kbxxlb99mcsbspxcai6hjydv4c46pwb67wwl2alb"))
(define rust-cpufeatures-0.3.1
  (crate "cpufeatures" "0.3.1" "0rkm1l35jy1z1yfg723fddsxc7vr0gc1hhfvc138hnqiwc58p8jw"))
(define rust-crc32fast-1.5.0
  (crate "crc32fast" "1.5.0" "04d51liy8rbssra92p0qnwjw8i9rm9c4m3bwy19wjamz1k4w30cl"))
(define rust-crossbeam-channel-0.5.15
  (crate "crossbeam-channel" "0.5.15" "1cicd9ins0fkpfgvz9vhz3m9rpkh6n8d3437c3wnfsdkd3wgif42"))
(define rust-crossbeam-utils-0.8.21
  (crate "crossbeam-utils" "0.8.21" "0a3aa2bmc8q35fb67432w16wvi54sfmb69rk9h5bhd18vw0c99fh"))
(define rust-crypto-common-0.1.7
  (crate "crypto-common" "0.1.7" "02nn2rhfy7kvdkdjl457q2z0mklcvj9h662xrq6dzhfialh2kj3q"))
(define rust-crypto-common-0.2.1
  (crate "crypto-common" "0.2.1" "041p8bs680hrg6rhicfifn19cfvybq9aya5i4i0k08d9byqpnwkp"))
(define rust-crypto-common-0.2.2
  (crate "crypto-common" "0.2.2" "0lql5wjlrjkd3r0w32rwbgqfmgg84ms3h65ldnlckmkc3nb4qvnf"))
(define rust-cssparser-0.29.6
  (crate "cssparser" "0.29.6" "1yp0zl5cmw9x95np9a51153fdb1ng8fgzwyssg7hr5dmki0h6ggr"))
(define rust-cssparser-0.36.0
  (crate "cssparser" "0.36.0" "1ljplaynfd8p9y00ypy84il27n1q9rz5pdnsb7b3pf5bq3wirrns"))
(define rust-cssparser-macros-0.6.1
  (crate "cssparser-macros" "0.6.1" "0cfkzj60avrnskdmaf7f8zw6pp3di4ylplk455zrzaf19ax8id8k"))
(define rust-ctor-0.2.9
  (crate "ctor" "0.2.9" "00b5vprqi4a2cr29xhqijg800b4dwkhrr5wj2kf3s7vnambpi8ij"))
(define rust-ctor-0.8.0
  (crate "ctor" "0.8.0" "164sj2zh0321m1rwbipq9vcndvfaxxh52vyvffnxdwdyyz13jb9m"))
(define rust-ctor-proc-macro-0.0.7
  (crate "ctor-proc-macro" "0.0.7" "1havwah6iryn0ang09y12xxr45jsp7ff27zflz4mhgk017ghlmjj"))
(define rust-ctutils-0.4.2
  (crate "ctutils" "0.4.2" "17m2s9jv7i780k26cq2fcyslg0pakv9plwdrmygdwha1hfiiambx"))
(define rust-ctutils-0.4.5
  (crate "ctutils" "0.4.5" "182gbkq9y4j8rpwyf2iwlvdpn5sw257fd8yizyrq1mkxmav8zliq"))
(define rust-darling-0.23.0
  (crate "darling" "0.23.0" "179fj6p6ajw4dnkrik51wjhifxwy02x5zhligyymcb905zd17bi5"))
(define rust-darling_core-0.23.0
  (crate "darling_core" "0.23.0" "1c033vrks38vpw8kwgd5w088dsr511kfz55n9db56prkgh7sarcq"))
(define rust-darling_macro-0.23.0
  (crate "darling_macro" "0.23.0" "13fvzji9xyp304mgq720z5l0xgm54qj68jibwscagkynggn88fdc"))
(define rust-data-encoding-2.11.0
  (crate "data-encoding" "2.11.0" "1j00wfmk4dzn4bnib07qlhylmd6a3kizwjz8mp00iix3vlamzbm4"))
(define rust-dbus-0.9.11
  (crate "dbus" "0.9.11" "0wxzld0baycxa4z6zrmnh68yy456b0f82j8wyp8wyymvj8ln0hmr"))
(define rust-dbus-secret-service-4.1.0
  (crate "dbus-secret-service" "4.1.0" "19jgbqb841kbzmfgaqnbbhsc5ijck7fzl3zvgqyyb2bqvyg512vh"))
(define rust-deflate64-0.1.12
  (crate "deflate64" "0.1.12" "1qj6a4y5b7jb6h8rgjj4b8lgi6b310hpn43fl6zn176z2rjr4sxc"))
(define rust-deranged-0.5.8
  (crate "deranged" "0.5.8" "0711df3w16vx80k55ivkwzwswziinj4dz05xci3rvmn15g615n3w"))
(define rust-derive_more-0.99.20
  (crate "derive_more" "0.99.20" "0zvz94kbc5d4r817wni1l7xk8f289nhf73vqk677p5rxlij4pnvf"))
(define rust-derive_more-2.1.1
  (crate "derive_more" "2.1.1" "0d5i10l4aff744jw7v4n8g6cv15rjk5mp0f1z522pc2nj7jfjlfp"))
(define rust-derive_more-impl-2.1.1
  (crate "derive_more-impl" "2.1.1" "1jwdp836vymp35d7mfvvalplkdgk2683nv3zjlx65n1194k9g6kr"))
(define rust-digest-0.10.7
  (crate "digest" "0.10.7" "14p2n6ih29x81akj097lvz7wi9b6b9hvls0lwrv7b6xwyy0s5ncy"))
(define rust-digest-0.11.2
  (crate "digest" "0.11.2" "0g0m77q7zfafm4jgy6i70wwimy9f41ywidbz9w467rh8px4xnl28"))
(define rust-digest-0.11.3
  (crate "digest" "0.11.3" "1hnmhd4rkybr11292w42pz9ppzx1h49glrhqg107k4s1b2xnvpgi"))
(define rust-directories-5.0.1
  (crate "directories" "5.0.1" "0dba6xzk79s1clqzxh2qlgzk3lmvvks1lzzjhhi3hd70hhxifjcs"))
(define rust-dirs-6.0.0
  (crate "dirs" "6.0.0" "0knfikii29761g22pwfrb8d0nqpbgw77sni9h2224haisyaams63"))
(define rust-dirs-sys-0.4.1
  (crate "dirs-sys" "0.4.1" "071jy0pvaad9lsa6mzawxrh7cmr7hsmsdxwzm7jzldfkrfjha3sj"))
(define rust-dirs-sys-0.5.0
  (crate "dirs-sys" "0.5.0" "1aqzpgq6ampza6v012gm2dppx9k35cdycbj54808ksbys9k366p0"))
(define rust-dispatch2-0.3.1
  (crate "dispatch2" "0.3.1" "0f5xmnbzpaz1g80m27kd804p75nswh0ikb6wvqh4ba3x9rz3c3hy"))
(define rust-displaydoc-0.2.5
  (crate "displaydoc" "0.2.5" "1q0alair462j21iiqwrr21iabkfnb13d6x5w95lkdg21q2xrqdlp"))
(define rust-displaydoc-0.2.6
  (crate "displaydoc" "0.2.6" "0kyxwfbdmagd8afzb2pzja7wj8dhah7smxdsgw00iq8pa2jhmiqs"))
(define rust-dlopen2-0.8.2
  (crate "dlopen2" "0.8.2" "1m647mg11ly4f78z34hcndkk4byn25z876y42pid2rlf2pa5nb2y"))
(define rust-dlopen2_derive-0.4.3
  (crate "dlopen2_derive" "0.4.3" "13vwwh48rlhb679cy15sxs0ppv3k4rkliv07hwx9k03mhy0vgfqg"))
(define rust-dom_query-0.27.0
  (crate "dom_query" "0.27.0" "129zrgwkfkp11g9izg3x7qzgqmimw0p858c33sd8vywa1h63h7jj"))
(define rust-dpi-0.1.2
  (crate "dpi" "0.1.2" "0xhsvzgjvdch2fwmfc9vkb708b0q59b6imypyjlgbiigyb74rcfq"))
(define rust-dtoa-1.0.11
  (crate "dtoa" "1.0.11" "1405jvczpxf1zd3nsvw02r50hr2k6argq6jkgdf04prd9s1g8g2c"))
(define rust-dtoa-short-0.3.5
  (crate "dtoa-short" "0.3.5" "11rwnkgql5jilsmwxpx6hjzkgyrbdmx1d71s0jyrjqm5nski25fd"))
(define rust-dtor-0.3.0
  (crate "dtor" "0.3.0" "1r6b2pvha5s0rml5hwf7bhh7ssvs6yzkzzfhivzqcw4qcin7s1gi"))
(define rust-dtor-proc-macro-0.0.6
  (crate "dtor-proc-macro" "0.0.6" "19fg0mivy9qyvbwmqj3ysj0qm5cay0gyp5fyw1imq89cj95cyy7n"))
(define rust-dunce-1.0.5
  (crate "dunce" "1.0.5" "04y8wwv3vvcqaqmqzssi6k0ii9gs6fpz96j5w9nky2ccsl23axwj"))
(define rust-dyn-clone-1.0.20
  (crate "dyn-clone" "1.0.20" "0m956cxcg8v2n8kmz6xs5zl13k2fak3zkapzfzzp7pxih6hix26h"))
(define rust-embed-resource-3.0.9
  (crate "embed-resource" "3.0.9" "1jsbckrpj5drij7rbz9svghrv8sshi3waj77iz8hxr3dsb48h6n3"))
(define rust-embed_plist-1.2.2
  (crate "embed_plist" "1.2.2" "1drvfi1lh9lh8b7pcqp98jdigzsji0kfavbrv126c69pbfgbixjf"))
(define rust-encoding_rs-0.8.35
  (crate "encoding_rs" "0.8.35" "1wv64xdrr9v37rqqdjsyb8l8wzlcbab80ryxhrszvnj59wy0y0vm"))
(define rust-endi-1.1.1
  (crate "endi" "1.1.1" "16a0076dx41vgrzzimm9clcym77h732czqjiajanmzvd1i1y5dv6"))
(define rust-enumflags2-0.7.12
  (crate "enumflags2" "0.7.12" "1vzcskg4dca2jiflsfx1p9yw1fvgzcakcs7cpip0agl51ilgf9qh"))
(define rust-enumflags2_derive-0.7.12
  (crate "enumflags2_derive" "0.7.12" "09rqffacafl1b83ir55hrah9gza0x7pzjn6lr6jm76fzix6qmiv7"))
(define rust-equivalent-1.0.2
  (crate "equivalent" "1.0.2" "03swzqznragy8n0x31lqc78g2af054jwivp7lkrbrc0khz74lyl7"))
(define rust-erased-serde-0.4.10
  (crate "erased-serde" "0.4.10" "1v1dy16ff8mck2rfqdmwdxl14phlvr8rq0i7yqzxka6ngnhdibfj"))
(define rust-errno-0.3.14
  (crate "errno" "0.3.14" "1szgccmh8vgryqyadg8xd58mnwwicf39zmin3bsn63df2wbbgjir"))
(define rust-event-listener-5.4.2
  (crate "event-listener" "5.4.2" "1lk9sv7r07l58jk263s18896l55mx9jv0g1rm4hj2mpi3paas8ss"))
(define rust-event-listener-strategy-0.5.4
  (crate "event-listener-strategy" "0.5.4" "14rv18av8s7n8yixg38bxp5vg2qs394rl1w052by5npzmbgz7scb"))
(define rust-fastrand-2.4.1
  (crate "fastrand" "2.4.1" "1mnqxxnxvd69ma9mczabpbbsgwlhd6l78yv3vd681453a9s247wz"))
(define rust-fdeflate-0.3.7
  (crate "fdeflate" "0.3.7" "130ga18vyxbb5idbgi07njymdaavvk6j08yh1dfarm294ssm6s0y"))
(define rust-field-offset-0.3.6
  (crate "field-offset" "0.3.6" "0zq5sssaa2ckmcmxxbly8qgz3sxpb8g1lwv90sdh1z74qif2gqiq"))
(define rust-filetime-0.2.27
  (crate "filetime" "0.2.27" "1nspbkm1d1km7xfljcbl565swqxrihqyin8bqppig2gf3qal927r"))
(define rust-find-msvc-tools-0.1.9
  (crate "find-msvc-tools" "0.1.9" "10nmi0qdskq6l7zwxw5g56xny7hb624iki1c39d907qmfh3vrbjv"))
(define rust-flate2-1.1.9
  (crate "flate2" "1.1.9" "0g2pb7cxnzcbzrj8bw4v6gpqqp21aycmf6d84rzb6j748qkvlgw4"))
(define rust-fnv-1.0.7
  (crate "fnv" "1.0.7" "1hc2mcqha06aibcaza94vbi81j6pr9a1bbxrxjfhc91zin8yr7iz"))
(define rust-foldhash-0.1.5
  (crate "foldhash" "0.1.5" "1wisr1xlc2bj7hk4rgkcjkz3j2x4dhd1h9lwk7mj8p71qpdgbi6r"))
(define rust-foldhash-0.2.0
  (crate "foldhash" "0.2.0" "1nvgylb099s11xpfm1kn2wcsql080nqmnhj1l25bp3r2b35j9kkp"))
(define rust-foreign-types-0.3.2
  (crate "foreign-types" "0.3.2" "1cgk0vyd7r45cj769jym4a6s7vwshvd0z4bqrb92q1fwibmkkwzn"))
(define rust-foreign-types-0.5.0
  (crate "foreign-types" "0.5.0" "0rfr2zfxnx9rz3292z5nyk8qs2iirznn5ff3rd4vgdwza6mdjdyp"))
(define rust-foreign-types-macros-0.2.3
  (crate "foreign-types-macros" "0.2.3" "0hjpii8ny6l7h7jpns2cp9589016l8mlrpaigcnayjn9bdc6qp0s"))
(define rust-foreign-types-shared-0.1.1
  (crate "foreign-types-shared" "0.1.1" "0jxgzd04ra4imjv8jgkmdq59kj8fsz6w4zxsbmlai34h26225c00"))
(define rust-foreign-types-shared-0.3.1
  (crate "foreign-types-shared" "0.3.1" "0nykdvv41a3d4py61bylmlwjhhvdm0b3bcj9vxhqgxaxnp5ik6ma"))
(define rust-form_urlencoded-1.2.2
  (crate "form_urlencoded" "1.2.2" "1kqzb2qn608rxl3dws04zahcklpplkd5r1vpabwga5l50d2v4k6b"))
(define rust-futf-0.1.5
  (crate "futf" "0.1.5" "0hvqk2r7v4fnc34hvc3vkri89gn52d5m9ihygmwn75l1hhp0whnz"))
(define rust-futures-channel-0.3.32
  (crate "futures-channel" "0.3.32" "07fcyzrmbmh7fh4ainilf1s7gnwvnk07phdq77jkb9fpa2ffifq7"))
(define rust-futures-core-0.3.32
  (crate "futures-core" "0.3.32" "07bbvwjbm5g2i330nyr1kcvjapkmdqzl4r6mqv75ivvjaa0m0d3y"))
(define rust-futures-executor-0.3.32
  (crate "futures-executor" "0.3.32" "17aplz3ns74qn7a04qg7qlgsdx5iwwwkd4jvdfra6hl3h4w9rwms"))
(define rust-futures-io-0.3.32
  (crate "futures-io" "0.3.32" "063pf5m6vfmyxj74447x8kx9q8zj6m9daamj4hvf49yrg9fs7jyf"))
(define rust-futures-lite-2.6.1
  (crate "futures-lite" "2.6.1" "1ba4dg26sc168vf60b1a23dv1d8rcf3v3ykz2psb7q70kxh113pp"))
(define rust-futures-macro-0.3.32
  (crate "futures-macro" "0.3.32" "0ys4b1lk7s0bsj29pv42bxsaavalch35rprp64s964p40c1bfdg8"))
(define rust-futures-sink-0.3.32
  (crate "futures-sink" "0.3.32" "14q8ml7hn5a6gyy9ri236j28kh0svqmrk4gcg0wh26rkazhm95y3"))
(define rust-futures-task-0.3.32
  (crate "futures-task" "0.3.32" "14s3vqf8llz3kjza33vn4ixg6kwxp61xrysn716h0cwwsnri2xq3"))
(define rust-futures-util-0.3.32
  (crate "futures-util" "0.3.32" "1mn60lw5kh32hz9isinjlpw34zx708fk5q1x0m40n6g6jq9a971q"))
(define rust-fxhash-0.2.1
  (crate "fxhash" "0.2.1" "037mb9ichariqi45xm6mz0b11pa92gj38ba0409z3iz239sns6y3"))
(define rust-gdk-0.18.2
  (crate "gdk" "0.18.2" "14967h4pac5gjyrd47yls4wbicrzhbwnd4ajisfwjyk2ijalbwnr"))
(define rust-gdk-pixbuf-0.18.5
  (crate "gdk-pixbuf" "0.18.5" "1v7svvl0g7zybndmis5inaqqgi1mvcc6s1n8rkb31f5zn3qzbqah"))
(define rust-gdk-pixbuf-sys-0.18.0
  (crate "gdk-pixbuf-sys" "0.18.0" "1xya543c4ffd2n7aiwwrdxsyc9casdbasafi6ixcknafckm3k61z"))
(define rust-gdk-sys-0.18.2
  (crate "gdk-sys" "0.18.2" "1xzkl9mdfsj1zja7ikrg3g8rinqsb9nqq64yc5k1xb4lhpri6baw"))
(define rust-gdkwayland-sys-0.18.2
  (crate "gdkwayland-sys" "0.18.2" "0sgyipcl2k39ybw7mk6mii17ggdgaphva2cz5dbzf8yj0vap200l"))
(define rust-gdkx11-0.18.2
  (crate "gdkx11" "0.18.2" "1zpvndnqasyk9gfnh8mwkb27gsr70dlkcg1v334bpgji8ghh1aiw"))
(define rust-gdkx11-sys-0.18.2
  (crate "gdkx11-sys" "0.18.2" "13a2yjqac7i6bqxkpdjfa5rf33v0v06jdnq12vqjdb01zr2p8bkf"))
(define rust-generic-array-0.14.7
  (crate "generic-array" "0.14.7" "16lyyrzrljfq424c3n8kfwkqihlimmsg5nhshbbp48np3yjrqr45"))
(define rust-gethostname-1.1.0
  (crate "gethostname" "1.1.0" "1n6bj9gh503ggjblfjcai96gmxynxsrykaynljlrfdra34q95m0v"))
(define rust-getrandom-0.1.16
  (crate "getrandom" "0.1.16" "1kjzmz60qx9mn615ks1akjbf36n3lkv27zfwbcam0fzmj56wphwg"))
(define rust-getrandom-0.2.17
  (crate "getrandom" "0.2.17" "1l2ac6jfj9xhpjjgmcx6s1x89bbnw9x6j9258yy6xjkzpq0bqapz"))
(define rust-getrandom-0.3.4
  (crate "getrandom" "0.3.4" "1zbpvpicry9lrbjmkd4msgj3ihff1q92i334chk7pzf46xffz7c9"))
(define rust-getrandom-0.4.2
  (crate "getrandom" "0.4.2" "0mb5833hf9pvn9dhvxjgfg5dx0m77g8wavvjdpvpnkp9fil1xr8d"))
(define rust-gio-0.18.4
  (crate "gio" "0.18.4" "0wsc6mnx057s4ailacg99dwgna38dbqli5x7a6y9rdw75x9qzz6l"))
(define rust-gio-sys-0.18.1
  (crate "gio-sys" "0.18.1" "1lip8z35iy9d184x2qwjxlbxi64q9cpayy7v1p5y9xdsa3w6smip"))
(define rust-glib-0.18.5
  (crate "glib" "0.18.5" "1r8fw0627nmn19bgk3xpmcfngx3wkn7mcpq5a8ma3risx3valg93"))
(define rust-glib-macros-0.18.5
  (crate "glib-macros" "0.18.5" "1p5cla53fcp195zp0hkqpmnn7iwmkdswhy7xh34002bw8y7j5c0b"))
(define rust-glib-sys-0.18.1
  (crate "glib-sys" "0.18.1" "164qhsfmlzd5mhyxs8123jzbdfldwxbikfpq5cysj3lddbmy4g06"))
(define rust-glob-0.3.3
  (crate "glob" "0.3.3" "106jpd3syfzjfj2k70mwm0v436qbx96wig98m4q8x071yrq35hhc"))
(define rust-global-hotkey-0.8.0
  (crate "global-hotkey" "0.8.0" "0bi4ix20wqvyddmnljwkrgxhnvsvk07lhx7xzwwjvjvh9856nf4c"))
(define rust-gobject-sys-0.18.0
  (crate "gobject-sys" "0.18.0" "0i6fhp3m6vs3wkzyc22rk2cqj68qvgddxmpaai34l72da5xi4l08"))
(define rust-gtk-0.18.2
  (crate "gtk" "0.18.2" "0sjh12mvvcmkz54nn30lb2xrzxagshbz1x2i4xfvshpwgccznmpx"))
(define rust-gtk-sys-0.18.2
  (crate "gtk-sys" "0.18.2" "0524c9mwx5jxkl8pb6q45g2n1kfwajz1isa0vnvkwmar3k1a2acg"))
(define rust-gtk3-macros-0.18.2
  (crate "gtk3-macros" "0.18.2" "179yszj83hgfxl4h4g2zfbsyn9a2zc5zrp6nzqv0fkzi45dkrzsj"))
(define rust-h2-0.4.19
  (crate "h2" "0.4.19" "05mw60jmsq97vjgj607nxjkx8dl6rxv6jj9i4r2z92056id5x3pg"))
(define rust-hashbrown-0.12.3
  (crate "hashbrown" "0.12.3" "1268ka4750pyg2pbgsr43f0289l5zah4arir2k4igx5a8c6fg7la"))
(define rust-hashbrown-0.15.5
  (crate "hashbrown" "0.15.5" "189qaczmjxnikm9db748xyhiw04kpmhm9xj9k9hg0sgx7pjwyacj"))
(define rust-hashbrown-0.17.0
  (crate "hashbrown" "0.17.0" "0l8gvcz80lvinb7x22h53cqbi2y1fm603y2jhhh9qwygvkb7sijg"))
(define rust-hashbrown-0.17.1
  (crate "hashbrown" "0.17.1" "0jmqz7i4yl6cm7rbn0i2ffkfrmwi6xkmzkaldr2v8bcsx2v0jngd"))
(define rust-heck-0.4.1
  (crate "heck" "0.4.1" "1a7mqsnycv5z4z5vnv1k34548jzmc0ajic7c1j8jsaspnhw5ql4m"))
(define rust-heck-0.5.0
  (crate "heck" "0.5.0" "1sjmpsdl8czyh9ywl3qcsfsq9a307dg4ni2vnlwgnzzqhc4y0113"))
(define rust-hermit-abi-0.5.2
  (crate "hermit-abi" "0.5.2" "1744vaqkczpwncfy960j2hxrbjl1q01csm84jpd9dajbdr2yy3zw"))
(define rust-hex-0.4.3
  (crate "hex" "0.4.3" "0w1a4davm1lgzpamwnba907aysmlrnygbqmfis2mqjx5m552a93z"))
(define rust-hkdf-0.12.4
  (crate "hkdf" "0.12.4" "1xxxzcarz151p1b858yn5skmhyrvn8fs4ivx5km3i1kjmnr8wpvv"))
(define rust-hmac-0.12.1
  (crate "hmac" "0.12.1" "0pmbr069sfg76z7wsssfk5ddcqd9ncp79fyz6zcm6yn115yc6jbc"))
(define rust-hmac-0.13.0
  (crate "hmac" "0.13.0" "0gw6avmix6ah63lf70dapxhml4dlcakl9f2lnm6b0hdf6abvq0v3"))
(define rust-html5ever-0.29.1
  (crate "html5ever" "0.29.1" "07518h5gbw0c6x7w5br76bgxvgphs6zlrb4q7ii7bg1ww7510x1v"))
(define rust-html5ever-0.38.0
  (crate "html5ever" "0.38.0" "1hnbs7d7v26gdgf6mm8rschsjrxazc139lik3q3f051gmqml6m0h"))
(define rust-http-1.4.0
  (crate "http" "1.4.0" "06iind4cwsj1d6q8c2xgq8i2wka4ps74kmws24gsi1bzdlw2mfp3"))
(define rust-http-1.4.2
  (crate "http" "1.4.2" "09b4p8fiivkg7wm0b59fyrn1jkm7px298ci7zb9igz6n647gaw39"))
(define rust-http-body-1.0.1
  (crate "http-body" "1.0.1" "111ir5k2b9ihz5nr9cz7cwm7fnydca7dx4hc7vr16scfzghxrzhy"))
(define rust-http-body-util-0.1.3
  (crate "http-body-util" "0.1.3" "0jm6jv4gxsnlsi1kzdyffjrj8cfr3zninnxpw73mvkxy4qzdj8dh"))
(define rust-httparse-1.10.1
  (crate "httparse" "1.10.1" "11ycd554bw2dkgw0q61xsa7a4jn1wb1xbfacmf3dbwsikvkkvgvd"))
(define rust-hybrid-array-0.4.11
  (crate "hybrid-array" "0.4.11" "1i878m874s249357fx3rzj4fx8b4rlrxw19vpnazwlgdl0vnim08"))
(define rust-hybrid-array-0.4.15
  (crate "hybrid-array" "0.4.15" "05wsyp2n5gyf49qk51mblj9qyb15aay74m6fwmf74mpv1pqn9y17"))
(define rust-hyper-1.10.1
  (crate "hyper" "1.10.1" "1624nwrh1ci34psqcl3q8q266kha8kd6fmqjj14qck49l59iqa2m"))
(define rust-hyper-1.9.0
  (crate "hyper" "1.9.0" "1jmwbwqcaficskg76kq402gbymbnh2z4v99xwq3l5aa6n8bg16b2"))
(define rust-hyper-rustls-0.27.9
  (crate "hyper-rustls" "0.27.9" "03vfnsm873wsp1dk0q85nxvk7w6syp8c2m5bcdjcyfgg4786ijik"))
(define rust-hyper-tls-0.6.0
  (crate "hyper-tls" "0.6.0" "1q36x2yps6hhvxq5r7mc8ph9zz6xlb573gx0x3yskb0fi736y83h"))
(define rust-hyper-util-0.1.20
  (crate "hyper-util" "0.1.20" "186zdc58hmm663csmjvrzgkr6jdh93sfmi3q2pxi57gcaqjpqm4n"))
(define rust-iana-time-zone-0.1.65
  (crate "iana-time-zone" "0.1.65" "0w64khw5p8s4nzwcf36bwnsmqzf61vpwk9ca1920x82bk6nwj6z3"))
(define rust-iana-time-zone-haiku-0.1.2
  (crate "iana-time-zone-haiku" "0.1.2" "17r6jmj31chn7xs9698r122mapq85mfnv98bb4pg6spm0si2f67k"))
(define rust-ico-0.5.0
  (crate "ico" "0.5.0" "0w9k20ssrwdaphqn5sc1na03xf4n3asl3jl5zx5z1q05avzmsy9y"))
(define rust-icu_collections-2.2.0
  (crate "icu_collections" "2.2.0" "070r7xd0pynm0hnc1v2jzlbxka6wf50f81wybf9xg0y82v6x3119"))
(define rust-icu_locale_core-2.2.0
  (crate "icu_locale_core" "2.2.0" "0a9cmin5w1x3bg941dlmgszn33qgq428k7qiqn5did72ndi9n8cj"))
(define rust-icu_normalizer-2.2.0
  (crate "icu_normalizer" "2.2.0" "1d7krxr0xpc4x9635k1100a24nh0nrc59n65j6yk6gbfkplmwvn5"))
(define rust-icu_normalizer_data-2.2.0
  (crate "icu_normalizer_data" "2.2.0" "0f5d5d5fhhr9937m2z6z38fzh6agf14z24kwlr6lyczafypf0fys"))
(define rust-icu_properties-2.2.0
  (crate "icu_properties" "2.2.0" "1pkh3s837808cbwxvfagwc28cvwrz2d9h5rl02jwrhm51ryvdqxy"))
(define rust-icu_properties_data-2.2.0
  (crate "icu_properties_data" "2.2.0" "052awny0qwkbcbpd5jg2cd7vl5ry26pq4hz1nfsgf10c3qhbnawf"))
(define rust-icu_provider-2.2.0
  (crate "icu_provider" "2.2.0" "08dl8pxbwr8zsz4c5vphqb7xw0hykkznwi4rw7bk6pwb3krlr70k"))
(define rust-id-arena-2.3.0
  (crate "id-arena" "2.3.0" "0m6rs0jcaj4mg33gkv98d71w3hridghp5c4yr928hplpkgbnfc1x"))
(define rust-ident_case-1.0.1
  (crate "ident_case" "1.0.1" "0fac21q6pwns8gh1hz3nbq15j8fi441ncl6w4vlnd1cmc55kiq5r"))
(define rust-idna-1.1.0
  (crate "idna" "1.1.0" "1pp4n7hppm480zcx411dsv9wfibai00wbpgnjj4qj0xa7kr7a21v"))
(define rust-idna_adapter-1.2.2
  (crate "idna_adapter" "1.2.2" "0557p76l8hj35r9zn1yv7c6x1c0qbrsffmg80n0yy8361ly3fs6b"))
(define rust-indexmap-1.9.3
  (crate "indexmap" "1.9.3" "16dxmy7yvk51wvnih3a3im6fp5lmx0wx76i03n06wyak6cwhw1xx"))
(define rust-indexmap-2.14.0
  (crate "indexmap" "2.14.0" "1na9z6f0d5pkjr1lgsni470v98gv2r7c41j8w48skr089x2yjrnl"))
(define rust-infer-0.19.0
  (crate "infer" "0.19.0" "1xzwzzg7s3i9jhcd304rb7b7838zkcysd67gmhffg4pxzmmr3255"))
(define rust-inout-0.1.4
  (crate "inout" "0.1.4" "008xfl1jn9rxsq19phnhbimccf4p64880jmnpg59wqi07kk117w7"))
(define rust-inout-0.2.2
  (crate "inout" "0.2.2" "1iq39s01d3y56j2r6hf75yqhpa7s2ifwr316yzyi0879a9jcwl22"))
(define rust-inout-0.2.4
  (crate "inout" "0.2.4" "0gwwh52wdf7yzsg6gg5256gpxq3l87kwkgqz21yhd6dkdyxq7s9w"))
(define rust-ipnet-2.12.0
  (crate "ipnet" "2.12.0" "1qpq2y0asyv0jppw7zww9y96fpnpinwap8a0phhqqgyy3znnz3yr"))
(define rust-iri-string-0.7.12
  (crate "iri-string" "0.7.12" "082fpx6c5ghvmqpwxaf2b268m47z2ic3prajqbmi1s1qpfj5kri5"))
(define rust-is-docker-0.2.0
  (crate "is-docker" "0.2.0" "1cyibrv6817cqcpf391m327ss40xlbik8wxcv5h9pj9byhksx2wj"))
(define rust-is-wsl-0.4.0
  (crate "is-wsl" "0.4.0" "19bs5pq221d4bknnwiqqkqrnsx2in0fsk8fylxm1747iim4hjdhp"))
(define rust-itoa-1.0.18
  (crate "itoa" "1.0.18" "10jnd1vpfkb8kj38rlkn2a6k02afvj3qmw054dfpzagrpl6achlg"))
(define rust-javascriptcore-rs-1.1.2
  (crate "javascriptcore-rs" "1.1.2" "1k3z4pmg46znxfmjqvx63d5zr9vdj070f97wgajzp3yfzzlp2mna"))
(define rust-javascriptcore-rs-sys-1.1.1
  (crate "javascriptcore-rs-sys" "1.1.1" "092igagxm561lx65sin2z18jpxzyg0288cfzcrdvg97z2j6yf6xg"))
(define rust-jni-0.21.1
  (crate "jni" "0.21.1" "15wczfkr2r45slsljby12ymf2hij8wi5b104ghck9byjnwmsm1qs"))
(define rust-jni-sys-0.3.1
  (crate "jni-sys" "0.3.1" "0n1j8fbz081w1igfrpc79n6vgm7h3ik34nziy5fjgq5nz7hm59j1"))
(define rust-jni-sys-0.4.1
  (crate "jni-sys" "0.4.1" "1wlahx6f2zhczdjqyn8mk7kshb8x5vsd927sn3lvw41rrf47ldy6"))
(define rust-jni-sys-macros-0.4.1
  (crate "jni-sys-macros" "0.4.1" "0r32gbabrak15a7p487765b5wc0jcna2yv88mk6m1zjqyi1bkh1q"))
(define rust-jobserver-0.1.34
  (crate "jobserver" "0.1.34" "0cwx0fllqzdycqn4d6nb277qx5qwnmjdxdl0lxkkwssx77j3vyws"))
(define rust-js-sys-0.3.102
  (crate "js-sys" "0.3.102" "0cgxklnyrfpzvf32cvdl3x5d070kfsv7ykdxfl3yizwdjqq4rl03"))
(define rust-js-sys-0.3.97
  (crate "js-sys" "0.3.97" "1kyaxgn1sm5am98jb48aj5j7r7s98kdrab41la5wzys5q2a0r151"))
(define rust-json-patch-3.0.1
  (crate "json-patch" "3.0.1" "023gm1q5xhhnhz7jqk009yb5wpjl4gckawgzxs82bg5nmzbjcdw6"))
(define rust-jsonptr-0.6.3
  (crate "jsonptr" "0.6.3" "0w6xkr6ns46nm3136x7www1dczz45y2bl9bsxmb2b6r3vlkjpsjx"))
(define rust-keyboard-types-0.7.0
  (crate "keyboard-types" "0.7.0" "12jjfk7dwa1cqp6wzw0xl1zzg3arsrnqy4afsynxn2csqfnxql5p"))
(define rust-keyring-3.6.3
  (crate "keyring" "3.6.3" "072mzc4rk2qffdlc8c5s9h38c6fifyr9xxmsix599ra4y2pw7g7f"))
(define rust-kuchikiki-0.8.8-speedreader
  (crate "kuchikiki" "0.8.8-speedreader" "1hhc4wccczgjiy7ir9g58cafm1xr2b0ra37s9bx36zv8fmqrgjq2"))
(define rust-lazy_static-1.5.0
  (crate "lazy_static" "1.5.0" "1zk6dqqni0193xg6iijh7i3i44sryglwgvx20spdvwk3r6sbrlmv"))
(define rust-leb128fmt-0.1.0
  (crate "leb128fmt" "0.1.0" "1chxm1484a0bly6anh6bd7a99sn355ymlagnwj3yajafnpldkv89"))
(define rust-libappindicator-0.9.0
  (crate "libappindicator" "0.9.0" "02nwjmm5qqbkvzbz4j1dd50xs0ywr0i2l2scwmxcqs680yb9nn03"))
(define rust-libappindicator-sys-0.9.0
  (crate "libappindicator-sys" "0.9.0" "1bsw2mcxil3zm4zzdir76i7xnaqaq30cd9qpviccrvdb70hwb7kf"))
(define rust-libbz2-rs-sys-0.2.3
  (crate "libbz2-rs-sys" "0.2.3" "0psnjha3lzksi5padx4y6a5s38d61v2k85cp7a7zqzh7cp0si9mk"))
(define rust-libbz2-rs-sys-0.2.5
  (crate "libbz2-rs-sys" "0.2.5" "0k6vyakpz7h1m00mywbqkk3fq0lcjbmr8n5s6l3jds1k6wrmgcrl"))
(define rust-libc-0.2.186
  (crate "libc" "0.2.186" "0rnyhzjyqq9x56skkllbjzzzwym3r61lq3l4hqj64v71gw0r3av8"))
(define rust-libdbus-sys-0.2.7
  (crate "libdbus-sys" "0.2.7" "0hzhq0dz6lfzmhsym9m95cfhjzrwq74qdg85xkpg2012sj4lg31j"))
(define rust-libloading-0.7.4
  (crate "libloading" "0.7.4" "17wbccnjvhjd9ibh019xcd8kjvqws8lqgq86lqkpbgig7gyq0wxn"))
(define rust-libredox-0.1.16
  (crate "libredox" "0.1.16" "0v54zvgknag9310wcjykgv86pgq02qr3mzgkdg4r6m1k7ns3nbz0"))
(define rust-libredox-0.1.17
  (crate "libredox" "0.1.17" "1ly9hnhiy0f6ccnlg3h8lca9smvv268gj5iwia4gnm10rsxbcaph"))
(define rust-linux-raw-sys-0.12.1
  (crate "linux-raw-sys" "0.12.1" "0lwasljrqxjjfk9l2j8lyib1babh2qjlnhylqzl01nihw14nk9ij"))
(define rust-litemap-0.8.2
  (crate "litemap" "0.8.2" "1w7628bc7wwcxc4n4s5kw0610xk06710nh2hn5kwwk2wa91z9nlj"))
(define rust-lock_api-0.4.14
  (crate "lock_api" "0.4.14" "0rg9mhx7vdpajfxvdjmgmlyrn20ligzqvn8ifmaz7dc79gkrjhr2"))
(define rust-log-0.4.29
  (crate "log" "0.4.29" "15q8j9c8g5zpkcw0hnd6cf2z7fxqnvsjh3rw5mv5q10r83i34l2y"))
(define rust-log-0.4.32
  (crate "log" "0.4.32" "0fmdg0cxig7i4fwf1sw7fmg4d1gdbfzniawcfpwydy1q7320fgwm"))
(define rust-lzma-rust2-0.16.2
  (crate "lzma-rust2" "0.16.2" "1binbd4v550sgyp1larz3dy1c0rz5lj33m0afb7pkdvgisc1xfs7"))
(define rust-lzma-rust2-0.22.0
  (crate "lzma-rust2" "0.22.0" "1fx3qa3jxv358fhgdihj8maqqy8s8yv7im9n68j2bp1949scjxvj"))
(define rust-mac-0.1.1
  (crate "mac" "0.1.1" "194vc7vrshqff72rl56f9xgb0cazyl4jda7qsv31m5l6xx7hq7n4"))
(define rust-mac-notification-sys-0.6.15
  (crate "mac-notification-sys" "0.6.15" "1jmyr75x4py3wzr1w8rgxw36a55sjvxw14qiaqdw3p4djmrljq7x"))
(define rust-markup5ever-0.14.1
  (crate "markup5ever" "0.14.1" "063sdq7hwxn2al9ygify8dd96mj57n9c4lig007lr1p128yj39y7"))
(define rust-markup5ever-0.38.0
  (crate "markup5ever" "0.38.0" "0qhqx70ak6pi9pbyddb61fhd37kypkbbvfnnnamfmzhm547x70w9"))
(define rust-match_token-0.1.0
  (crate "match_token" "0.1.0" "0sx3212vkjqfblfhr556ayabbjflbigjf5j591j9kgs4infniac8"))
(define rust-matchers-0.2.0
  (crate "matchers" "0.2.0" "1sasssspdj2vwcwmbq3ra18d3qniapkimfcbr47zmx6750m5llni"))
(define rust-matches-0.1.10
  (crate "matches" "0.1.10" "1994402fq4viys7pjhzisj4wcw894l53g798kkm2y74laxk0jci5"))
(define rust-md5-0.7.0
  (crate "md5" "0.7.0" "0wcps37hrhz59fkhf8di1ppdnqld6l1w5sdy7jp7p51z0i4c8329"))
(define rust-memchr-2.8.0
  (crate "memchr" "2.8.0" "0y9zzxcqxvdqg6wyag7vc3h0blhdn7hkq164bxyx2vph8zs5ijpq"))
(define rust-memchr-2.8.2
  (crate "memchr" "2.8.2" "1i33wr49pcz2sbd12nds3n9fszay8kq5bk78gwciz462mcs49448"))
(define rust-memoffset-0.9.1
  (crate "memoffset" "0.9.1" "12i17wh9a9plx869g7j4whf62xw68k5zd4k0k5nh6ys5mszid028"))
(define rust-mime-0.3.17
  (crate "mime" "0.3.17" "16hkibgvb9klh0w0jk5crr5xv90l3wlf77ggymzjmvl1818vnxv8"))
(define rust-mime_guess-2.0.5
  (crate "mime_guess" "2.0.5" "03jmg3yx6j39mg0kayf7w4a886dl3j15y8zs119zw01ccy74zi7p"))
(define rust-miniz_oxide-0.8.9
  (crate "miniz_oxide" "0.8.9" "05k3pdg8bjjzayq3rf0qhpirq9k37pxnasfn4arbs17phqn6m9qz"))
(define rust-mio-1.2.0
  (crate "mio" "1.2.0" "1hanrh4fwsfkdqdaqfidz48zz1wdix23zwn3r2x78am0garfbdsh"))
(define rust-mio-1.2.1
  (crate "mio" "1.2.1" "1nkggmrlnjs93w8rja4lvjj4aml1xqahgimv1h0p7d373kvhmg82"))
(define rust-muda-0.17.2
  (crate "muda" "0.17.2" "0xv1x0rgzr9pi63074rg1f7qz0q5lrihblbqsy1h71l99rdfr7vw"))
(define rust-muda-0.19.2
  (crate "muda" "0.19.2" "132jj9z8sjjb6x6vnv7ai0gjn2pfz9l2d527cv325lwwz3gy78j7"))
(define rust-native-tls-0.2.18
  (crate "native-tls" "0.2.18" "1wmv0g5p6jwyyslyw88w5fv9kc9qvjd1hi2d4sfl4qm19vhh0ma6"))
(define rust-ndk-0.9.0
  (crate "ndk" "0.9.0" "1m32zpmi5w1pf3j47k6k5fw395dc7aj8d0mdpsv53lqkprxjxx63"))
(define rust-ndk-context-0.1.1
  (crate "ndk-context" "0.1.1" "12sai3dqsblsvfd1l1zab0z6xsnlha3xsfl7kagdnmj3an3jvc17"))
(define rust-ndk-sys-0.6.0-11769913
  (crate "ndk-sys" "0.6.0+11769913" "0wx8r6pji20if4xs04g73gxl98nmjrfc73z0v6w1ypv6a4qdlv7f"))
(define rust-new_debug_unreachable-1.0.6
  (crate "new_debug_unreachable" "1.0.6" "11phpf1mjxq6khk91yzcbd3ympm78m3ivl7xg6lg2c0lf66fy3k5"))
(define rust-nix-0.29.0
  (crate "nix" "0.29.0" "0ikvn7s9r2lrfdm3mx1h7nbfjvcc6s9vxdzw7j5xfkd2qdnp9qki"))
(define rust-nix-0.31.3
  (crate "nix" "0.31.3" "0gbwnjfny9rq9hl5bz4ry520n9rnfknna4bg88n66f7zx3yx486g"))
(define rust-nodrop-0.1.14
  (crate "nodrop" "0.1.14" "1fz1v9r8ijacf0hlq0pdv5l9mz8vgqg1snmhvpjmi9aci1b4mvvj"))
(define rust-notify-rust-4.18.0
  (crate "notify-rust" "4.18.0" "14dqk7l4nhr9dfk30lx11mkv6rym1vfx6jbs7bv2b7xayasc3d65"))
(define rust-nu-ansi-term-0.50.3
  (crate "nu-ansi-term" "0.50.3" "1ra088d885lbd21q1bxgpqdlk1zlndblmarn948jz2a40xsbjmvr"))
(define rust-num-0.4.3
  (crate "num" "0.4.3" "08yb2fc1psig7pkzaplm495yp7c30m4pykpkwmi5bxrgid705g9m"))
(define rust-num-bigint-0.4.6
  (crate "num-bigint" "0.4.6" "1f903zd33i6hkjpsgwhqwi2wffnvkxbn6rv4mkgcjcqi7xr4zr55"))
(define rust-num-complex-0.4.6
  (crate "num-complex" "0.4.6" "15cla16mnw12xzf5g041nxbjjm9m85hdgadd5dl5d0b30w9qmy3k"))
(define rust-num-conv-0.2.1
  (crate "num-conv" "0.2.1" "0rqrr29brafaa2za352pbmhkk556n7f8z9rrkgmjp1idvdl3fry6"))
(define rust-num-conv-0.2.2
  (crate "num-conv" "0.2.2" "0hg4f9bwmy7cwpxdkm165dmkfc8jhkkayci234jsmi5ssb33j5sj"))
(define rust-num-integer-0.1.46
  (crate "num-integer" "0.1.46" "13w5g54a9184cqlbsq80rnxw4jj4s0d8wv75jsq5r2lms8gncsbr"))
(define rust-num-iter-0.1.45
  (crate "num-iter" "0.1.45" "1gzm7vc5g9qsjjl3bqk9rz1h6raxhygbrcpbfl04swlh0i506a8l"))
(define rust-num-rational-0.4.2
  (crate "num-rational" "0.4.2" "093qndy02817vpgcqjnj139im3jl7vkq4h68kykdqqh577d18ggq"))
(define rust-num-traits-0.2.19
  (crate "num-traits" "0.2.19" "0h984rhdkkqd4ny9cif7y2azl3xdfb7768hb9irhpsch4q3gq787"))
(define rust-num_enum-0.7.6
  (crate "num_enum" "0.7.6" "09kg0c2y08npdv0c9dbm4m9a9wz8w2qaiqqxl4gj3v22hj1wl2sx"))
(define rust-num_enum_derive-0.7.6
  (crate "num_enum_derive" "0.7.6" "1y0x9z49s27vdas6mglqbv02sgkdmbr8ns2kwspzrp2ra81rh2b8"))
(define rust-objc2-0.6.4
  (crate "objc2" "0.6.4" "17x8qpl512frscfqbmgjr20kg3y4r0xdqxphja17dz5f0znsh4is"))
(define rust-objc2-app-kit-0.3.2
  (crate "objc2-app-kit" "0.3.2" "132ijwni8lsi8phq7wnmialkxp46zx998fns3zq5np0ya1mr77nl"))
(define rust-objc2-cloud-kit-0.3.2
  (crate "objc2-cloud-kit" "0.3.2" "0714xrydi9wvh25s2110sjfpx9mv4xs9p4ys71q8fhxvh3c79bbk"))
(define rust-objc2-core-data-0.3.2
  (crate "objc2-core-data" "0.3.2" "1ylqsa6hpma7k4090pkil8b7c0i8dcxnh46zwhnfidgv7rjjlh0b"))
(define rust-objc2-core-foundation-0.3.2
  (crate "objc2-core-foundation" "0.3.2" "0dnmg7606n4zifyjw4ff554xvjmi256cs8fpgpdmr91gckc0s61a"))
(define rust-objc2-core-graphics-0.3.2
  (crate "objc2-core-graphics" "0.3.2" "01x8413pxq0m5rwidlaczni8v5cz9dc3xqzq8l9zlpl9cv8cj8p0"))
(define rust-objc2-core-image-0.3.2
  (crate "objc2-core-image" "0.3.2" "01phi7cx2k32a8x45qr0y1623l2b8gg764c6isgj15rbinrn7mg5"))
(define rust-objc2-core-location-0.3.2
  (crate "objc2-core-location" "0.3.2" "02908pp1knq64wjq07zd6q2z77qppdpd7l2z0by77jabw8a74d6a"))
(define rust-objc2-core-text-0.3.2
  (crate "objc2-core-text" "0.3.2" "0bfrzqxhgh4y1imk1bb9g0v28g0frigls6hnc942npfj93xhvphc"))
(define rust-objc2-encode-4.1.0
  (crate "objc2-encode" "4.1.0" "0cqckp4cpf68mxyc2zgnazj8klv0z395nsgbafa61cjgsyyan9gg"))
(define rust-objc2-exception-helper-0.1.1
  (crate "objc2-exception-helper" "0.1.1" "12nrg6fhhp2rzmnym6s37h7w9v9sa9wbaixvfsq3axrdnzxwb8f7"))
(define rust-objc2-foundation-0.3.2
  (crate "objc2-foundation" "0.3.2" "0wijkxzzvw2xkzssds3fj8279cbykz2rz9agxf6qh7y2agpsvq73"))
(define rust-objc2-io-surface-0.3.2
  (crate "objc2-io-surface" "0.3.2" "07fqx4fmwydf2arrc4xs4awv7zyzzxh60fyqdfmrpm9n148qh1qq"))
(define rust-objc2-quartz-core-0.3.2
  (crate "objc2-quartz-core" "0.3.2" "07vzaf6y1lk7zygkgvpp23mm19ipdm9yq8af22gvywdkaa23bhcn"))
(define rust-objc2-ui-kit-0.3.2
  (crate "objc2-ui-kit" "0.3.2" "08mbgqg8pffclyxpz2lr8r1fv8wn2i4m1k6bk1s5fvy06f766zfq"))
(define rust-objc2-user-notifications-0.3.2
  (crate "objc2-user-notifications" "0.3.2" "0gk1frfj875pkbz3ncs8swvjgdipz3vwq5l42vd3rxzypf615ycx"))
(define rust-objc2-web-kit-0.3.2
  (crate "objc2-web-kit" "0.3.2" "0zqyflb4r2igpg5s48fmjbcajikvdbwpm7fzf3s3qhqck2msmrdj"))
(define rust-once_cell-1.21.4
  (crate "once_cell" "1.21.4" "0l1v676wf71kjg2khch4dphwh1jp3291ffiymr2mvy1kxd5kwz4z"))
(define rust-open-5.3.4
  (crate "open" "5.3.4" "1z9pbnc0lx1lqx1p74szfar7rv21shcggkjzyymmga19giqsnfwz"))
(define rust-open-5.3.5
  (crate "open" "5.3.5" "0b691z6jf5gk3sbjmq5qhg22iyngm3p6kprsib3p716w5nfsifig"))
(define rust-openssl-0.10.78
  (crate "openssl" "0.10.78" "08lj1fvhpfcga3nxs40vnl4spxfrswljvncxqwyazniw85r4737k"))
(define rust-openssl-0.10.81
  (crate "openssl" "0.10.81" "0ibsv2ppsjrp62jqyzprhay9vczk1bw9xvdr3h4h7fxsy0kkm0kp"))
(define rust-openssl-macros-0.1.1
  (crate "openssl-macros" "0.1.1" "173xxvfc63rr5ybwqwylsir0vq6xsj4kxiv4hmg4c3vscdmncj59"))
(define rust-openssl-probe-0.2.1
  (crate "openssl-probe" "0.2.1" "1gpwpb7smfhkscwvbri8xzbab39wcnby1jgz1s49vf1aqgsdx1vw"))
(define rust-openssl-sys-0.9.114
  (crate "openssl-sys" "0.9.114" "1dhvfj1nvikl4gaq9zb9ka2g7r67n03pb3s3vg7w9z07rm2i5khk"))
(define rust-openssl-sys-0.9.117
  (crate "openssl-sys" "0.9.117" "159nf6jsqnmsynkh6gjzx088q1ifll7v88sss8qdk363n9mpwzml"))
(define rust-option-ext-0.2.0
  (crate "option-ext" "0.2.0" "0zbf7cx8ib99frnlanpyikm1bx8qn8x602sw1n7bg6p9x94lyx04"))
(define rust-ordered-stream-0.2.0
  (crate "ordered-stream" "0.2.0" "0l0xxp697q7wiix1gnfn66xsss7fdhfivl2k7bvpjs4i3lgb18ls"))
(define rust-os_pipe-1.2.3
  (crate "os_pipe" "1.2.3" "0rqrvm7fdp790b4ks3kcdzsgkz2528xrn3vxc9l4nf1inj2ax3vx"))
(define rust-pango-0.18.3
  (crate "pango" "0.18.3" "1r5ygq7036sv7w32kp8yxr6vgggd54iaavh3yckanmq4xg0px8kw"))
(define rust-pango-sys-0.18.0
  (crate "pango-sys" "0.18.0" "1iaxalcaaj59cl9n10svh4g50v8jrc1a36kd7n9yahx8j7ikfrs3"))
(define rust-parking-2.2.1
  (crate "parking" "2.2.1" "1fnfgmzkfpjd69v4j9x737b1k8pnn054bvzcn5dm3pkgq595d3gk"))
(define rust-parking_lot-0.12.5
  (crate "parking_lot" "0.12.5" "06jsqh9aqmc94j2rlm8gpccilqm6bskbd67zf6ypfc0f4m9p91ck"))
(define rust-parking_lot_core-0.9.12
  (crate "parking_lot_core" "0.9.12" "1hb4rggy70fwa1w9nb0svbyflzdc69h047482v2z3sx2hmcnh896"))
(define rust-pathdiff-0.2.3
  (crate "pathdiff" "0.2.3" "1lrqp4ip05df8dzldq6gb2c1sq2gs54gly8lcnv3rhav1qhwx56z"))
(define rust-pbkdf2-0.13.0
  (crate "pbkdf2" "0.13.0" "0a867f3jikfwjfni9fhmrjhdb7qcjzjd917lk96m5gy5p3784b8i"))
(define rust-percent-encoding-2.3.2
  (crate "percent-encoding" "2.3.2" "083jv1ai930azvawz2khv7w73xh8mnylk7i578cifndjn5y64kwv"))
(define rust-phf-0.10.1
  (crate "phf" "0.10.1" "0naj8n5nasv5hj5ldlva3cl6y3sv7zp3kfgqylhbrg55v3mg3fzs"))
(define rust-phf-0.11.3
  (crate "phf" "0.11.3" "0y6hxp1d48rx2434wgi5g8j1pr8s5jja29ha2b65435fh057imhz"))
(define rust-phf-0.13.1
  (crate "phf" "0.13.1" "1pzswx5gdglgjgp4azyzwyr4gh031r0kcnpqq6jblga72z3jsmn1"))
(define rust-phf-0.8.0
  (crate "phf" "0.8.0" "04pyv8bzqvw69rd5dynd5nb85py1hf7wa4ixyhrvdz1l5qin3yrx"))
(define rust-phf_codegen-0.11.3
  (crate "phf_codegen" "0.11.3" "0si1n6zr93kzjs3wah04ikw8z6npsr39jw4dam8yi9czg2609y5f"))
(define rust-phf_codegen-0.13.1
  (crate "phf_codegen" "0.13.1" "1qfnsl2hiny0yg4lwn888xla5iwccszgxnx8dhbwl6s2h2fpzaj9"))
(define rust-phf_codegen-0.8.0
  (crate "phf_codegen" "0.8.0" "05d8w7aqqjb6039pfm6404gk5dlwrrf97kiy1n21212vb1hyxzyb"))
(define rust-phf_generator-0.10.0
  (crate "phf_generator" "0.10.0" "1mlq6hlajsvlsx6rhw49g9ricsm017lrxmgmmbk85sxm7f4qaljx"))
(define rust-phf_generator-0.11.3
  (crate "phf_generator" "0.11.3" "0gc4np7s91ynrgw73s2i7iakhb4lzdv1gcyx7yhlc0n214a2701w"))
(define rust-phf_generator-0.13.1
  (crate "phf_generator" "0.13.1" "0dwpp11l41dy9mag4phkyyvhpf66lwbp79q3ik44wmhyfqxcwnhk"))
(define rust-phf_generator-0.8.0
  (crate "phf_generator" "0.8.0" "09i5338d1kixq6a60fcayz6awgxjlxcfw9ic5f02abbgr067ydhp"))
(define rust-phf_macros-0.10.0
  (crate "phf_macros" "0.10.0" "1q5ljwvb10dx188i6jxzckqfimjw5pm2p4kkvmhg2q6m9lcg7zaq"))
(define rust-phf_macros-0.11.3
  (crate "phf_macros" "0.11.3" "05kjfbyb439344rhmlzzw0f9bwk9fp95mmw56zs7yfn1552c0jpq"))
(define rust-phf_macros-0.13.1
  (crate "phf_macros" "0.13.1" "1vv9h8pr7xh18sigpvq1hxc8q9nmjmv6gdpqsp65krxiahmh6bw1"))
(define rust-phf_shared-0.10.0
  (crate "phf_shared" "0.10.0" "15n02nc8yqpd8hbxngblar2g53p3nllc93d8s8ih3p5cf7bnlydn"))
(define rust-phf_shared-0.11.3
  (crate "phf_shared" "0.11.3" "1rallyvh28jqd9i916gk5gk2igdmzlgvv5q0l3xbf3m6y8pbrsk7"))
(define rust-phf_shared-0.13.1
  (crate "phf_shared" "0.13.1" "0rpjchnswm0x5l4mz9xqfpw0j4w68sjvyqrdrv13h7lqqmmyyzz5"))
(define rust-phf_shared-0.8.0
  (crate "phf_shared" "0.8.0" "1xssnqrrcn0nr9ayqrnm8xm37ac4xvwcx8pax7jxss7yxawzh360"))
(define rust-pin-project-lite-0.2.17
  (crate "pin-project-lite" "0.2.17" "1kfmwvs271si96zay4mm8887v5khw0c27jc9srw1a75ykvgj54x8"))
(define rust-piper-0.2.5
  (crate "piper" "0.2.5" "1hd3j94mw5dwc457gs9ssb2r5b9iipywndf5srqx7pj38jd4fdf8"))
(define rust-pkg-config-0.3.33
  (crate "pkg-config" "0.3.33" "17jnqmcbxsnwhg9gjf0nh6dj5k0x3hgwi3mb9krjnmfa9v435w8r"))
(define rust-plain-0.2.3
  (crate "plain" "0.2.3" "19n1xbxb4wa7w891268bzf6cbwq4qvdb86bik1z129qb0xnnnndl"))
(define rust-plist-1.9.0
  (crate "plist" "1.9.0" "1wa6kk1179hxn0dd0sw99jcz4053lfxwzgavnv0p6qh2iqkr29q9"))
(define rust-png-0.17.16
  (crate "png" "0.17.16" "09kmkms9fmkbkarw0lnf0scqvjwwg3r7riddag0i3q39r0pil5c2"))
(define rust-png-0.18.1
  (crate "png" "0.18.1" "0qca282xp8a6d7mikxrwji3f52mjn4vnqxz2v9iz5adj665rnxk0"))
(define rust-polling-3.11.0
  (crate "polling" "3.11.0" "0622qfbxi3gb0ly2c99n3xawp878fkrd1sl83hjdhisx11cly3jx"))
(define rust-potential_utf-0.1.5
  (crate "potential_utf" "0.1.5" "0r0518fr32xbkgzqap509s3r60cr0iancsg9j1jgf37cyz7b20q1"))
(define rust-powerfmt-0.2.0
  (crate "powerfmt" "0.2.0" "14ckj2xdpkhv3h6l5sdmb9f1d57z8hbfpdldjc2vl5givq2y77j3"))
(define rust-ppmd-rust-1.4.0
  (crate "ppmd-rust" "1.4.0" "092s8ncdrqdxgnxk0ii4ffs664swpnp107vriz4x2ycsl6alrjpg"))
(define rust-ppv-lite86-0.2.21
  (crate "ppv-lite86" "0.2.21" "1abxx6qz5qnd43br1dd9b2savpihzjza8gb4fbzdql1gxp2f7sl5"))
(define rust-precomputed-hash-0.1.1
  (crate "precomputed-hash" "0.1.1" "075k9bfy39jhs53cb2fpb9klfakx2glxnf28zdw08ws6lgpq6lwj"))
(define rust-prettyplease-0.2.37
  (crate "prettyplease" "0.2.37" "0azn11i1kh0byabhsgab6kqs74zyrg69xkirzgqyhz6xmjnsi727"))
(define rust-proc-macro-crate-1.3.1
  (crate "proc-macro-crate" "1.3.1" "069r1k56bvgk0f58dm5swlssfcp79im230affwk6d9ck20g04k3z"))
(define rust-proc-macro-crate-2.0.2
  (crate "proc-macro-crate" "2.0.2" "092x5acqnic14cw6vacqap5kgknq3jn4c6jij9zi6j85839jc3xh"))
(define rust-proc-macro-crate-3.5.0
  (crate "proc-macro-crate" "3.5.0" "0kv1g1d1zjwxlgcaba2qlshzyy32j03xic8rskqlcr5mnblsfyz6"))
(define rust-proc-macro-error-1.0.4
  (crate "proc-macro-error" "1.0.4" "1373bhxaf0pagd8zkyd03kkx6bchzf6g0dkwrwzsnal9z47lj9fs"))
(define rust-proc-macro-error-attr-1.0.4
  (crate "proc-macro-error-attr" "1.0.4" "0sgq6m5jfmasmwwy8x4mjygx5l7kp8s4j60bv25ckv2j1qc41gm1"))
(define rust-proc-macro-hack-0.5.20-deprecated
  (crate "proc-macro-hack" "0.5.20+deprecated" "0s402hmcs3k9nd6rlp07zkr1lz7yimkmcwcbgnly2zr44wamwdyw"))
(define rust-proc-macro2-1.0.106
  (crate "proc-macro2" "1.0.106" "0d09nczyaj67x4ihqr5p7gxbkz38gxhk4asc0k8q23g9n85hzl4g"))
(define rust-quick-xml-0.39.2
  (crate "quick-xml" "0.39.2" "0z86jkw618p0d7q3zqp7pzh7cnf7wwlanzx8gyma3dffwzl233wm"))
(define rust-quick-xml-0.39.4
  (crate "quick-xml" "0.39.4" "0plfhnna58ad2hlym3q02zrmmh7xdpikzs7hll4x6w7nwba8vk6d"))
(define rust-quote-1.0.45
  (crate "quote" "1.0.45" "095rb5rg7pbnwdp6v8w5jw93wndwyijgci1b5lw8j1h5cscn3wj1"))
(define rust-r-efi-5.3.0
  (crate "r-efi" "5.3.0" "03sbfm3g7myvzyylff6qaxk4z6fy76yv860yy66jiswc2m6b7kb9"))
(define rust-r-efi-6.0.0
  (crate "r-efi" "6.0.0" "1gyrl2k5fyzj9k7kchg2n296z5881lg7070msabid09asp3wkp7q"))
(define rust-rand-0.7.3
  (crate "rand" "0.7.3" "00sdaimkbz491qgi6qxkv582yivl32m2jd401kzbn94vsiwicsva"))
(define rust-rand-0.8.6
  (crate "rand" "0.8.6" "12kd4rljn86m00rcaz4c1rcya4mb4gk5ig6i8xq00a8wjgxfr82w"))
(define rust-rand-0.9.5
  (crate "rand" "0.9.5" "0hbvllk8g28mqjld6hqmckk69w296qpzg95whm3didsyg46ivvxr"))
(define rust-rand_chacha-0.2.2
  (crate "rand_chacha" "0.2.2" "00il36fkdbsmpr99p9ksmmp6dn1md7rmnwmz0rr77jbrca2yvj7l"))
(define rust-rand_chacha-0.3.1
  (crate "rand_chacha" "0.3.1" "123x2adin558xbhvqb8w4f6syjsdkmqff8cxwhmjacpsl1ihmhg6"))
(define rust-rand_chacha-0.9.0
  (crate "rand_chacha" "0.9.0" "1jr5ygix7r60pz0s1cv3ms1f6pd1i9pcdmnxzzhjc3zn3mgjn0nk"))
(define rust-rand_core-0.5.1
  (crate "rand_core" "0.5.1" "06bdvx08v3rkz451cm7z59xwwqn1rkfh6v9ay77b14f8dwlybgch"))
(define rust-rand_core-0.6.4
  (crate "rand_core" "0.6.4" "0b4j2v4cb5krak1pv6kakv4sz6xcwbrmy2zckc32hsigbrwy82zc"))
(define rust-rand_core-0.9.5
  (crate "rand_core" "0.9.5" "0g6qc5r3f0hdmz9b11nripyp9qqrzb0xqk9piip8w8qlvqkcibvn"))
(define rust-rand_hc-0.2.0
  (crate "rand_hc" "0.2.0" "0g31sqwpmsirdlwr0svnacr4dbqyz339im4ssl9738cjgfpjjcfa"))
(define rust-rand_pcg-0.2.1
  (crate "rand_pcg" "0.2.1" "0ab4h6s6x3py833jk61lwadq83qd1c8bih2hgi6yps9rnv0x1aqn"))
(define rust-raw-window-handle-0.6.2
  (crate "raw-window-handle" "0.6.2" "0ff5c648hncwx7hm2a8fqgqlbvbl4xawb6v3xxv9wkpjyrr5arr0"))
(define rust-redox_syscall-0.5.18
  (crate "redox_syscall" "0.5.18" "0b9n38zsxylql36vybw18if68yc9jczxmbyzdwyhb9sifmag4azd"))
(define rust-redox_syscall-0.7.4
  (crate "redox_syscall" "0.7.4" "0fk4infcfn2hvshrwgf7r48rf9mr1zxy1a28d7xn798x7ffasl7l"))
(define rust-redox_users-0.4.6
  (crate "redox_users" "0.4.6" "0hya2cxx6hxmjfxzv9n8rjl5igpychav7zfi1f81pz6i4krry05s"))
(define rust-redox_users-0.5.2
  (crate "redox_users" "0.5.2" "1b17q7gf7w8b1vvl53bxna24xl983yn7bd00gfbii74bcg30irm4"))
(define rust-ref-cast-1.0.25
  (crate "ref-cast" "1.0.25" "0zdzc34qjva9xxgs889z5iz787g81hznk12zbk4g2xkgwq530m7k"))
(define rust-ref-cast-impl-1.0.25
  (crate "ref-cast-impl" "1.0.25" "1nkhn1fklmn342z5c4mzfzlxddv3x8yhxwwk02cj06djvh36065p"))
(define rust-regex-1.12.3
  (crate "regex" "1.12.3" "0xp2q0x7ybmpa5zlgaz00p8zswcirj9h8nry3rxxsdwi9fhm81z1"))
(define rust-regex-1.12.4
  (crate "regex" "1.12.4" "1fm6si2xpmhwqflabdqsakc0qkq718wx2ljl37nbj75fb5vjnagi"))
(define rust-regex-automata-0.4.14
  (crate "regex-automata" "0.4.14" "13xf7hhn4qmgfh784llcp2kzrvljd13lb2b1ca0mwnf15w9d87bf"))
(define rust-regex-syntax-0.8.10
  (crate "regex-syntax" "0.8.10" "02jx311ka0daxxc7v45ikzhcl3iydjbbb0mdrpc1xgg8v7c7v2fw"))
(define rust-regex-syntax-0.8.11
  (crate "regex-syntax" "0.8.11" "1m25h5q2wp976fb9gc3dsc9l99svcvd5cri8lncb51c46ydgzxnn"))
(define rust-reqwest-0.12.28
  (crate "reqwest" "0.12.28" "0iqidijghgqbzl3bjg5hb4zmigwa4r612bgi0yiq0c90b6jkrpgd"))
(define rust-reqwest-0.13.3
  (crate "reqwest" "0.13.3" "1h7fgnllk7ihw7836b7z73h9fb5vk90y3irvcm0ysan2l8g05q32"))
(define rust-reqwest-0.13.4
  (crate "reqwest" "0.13.4" "1hy1plns9krbh3h1dy2sdjygsfkdcnxm6pbxdi0ya9b5vq8mi711"))
(define rust-rfd-0.16.0
  (crate "rfd" "0.16.0" "0wi62lvcs2zrk4z8667hil992ijfkgckak7pv0vj9abhkryxfnm1"))
(define rust-ring-0.17.14
  (crate "ring" "0.17.14" "1dw32gv19ccq4hsx3ribhpdzri1vnrlcfqb2vj41xn4l49n9ws54"))
(define rust-rustc-hash-2.1.2
  (crate "rustc-hash" "2.1.2" "1gjdc5bw9982cj176jvgz9rrqf9xvr1q1ddpzywf5qhs7yzhlc4l"))
(define rust-rustc_version-0.4.1
  (crate "rustc_version" "0.4.1" "14lvdsmr5si5qbqzrajgb6vfn69k0sfygrvfvr2mps26xwi3mjyg"))
(define rust-rustix-1.1.4
  (crate "rustix" "1.1.4" "14511f9yjqh0ix07xjrjpllah3325774gfwi9zpq72sip5jlbzmn"))
(define rust-rustls-0.23.46
  (crate "rustls" "0.23.46" "1pwg7i8drr70374amj96952cils9mpwyijd5rx1mqdp9q3c3pqa8"))
(define rust-rustls-pki-types-1.14.1
  (crate "rustls-pki-types" "1.14.1" "1a9pr54y0f3qr97bxpd3ahjldq0gqdld0h799xbnwdzbwxx1k9rh"))
(define rust-rustls-webpki-0.103.16
  (crate "rustls-webpki" "0.103.16" "10djm2f00xzi5qlbcfqjhhn2smk2h9aw8b4l74qncz4xsfvb2hs4"))
(define rust-rustversion-1.0.22
  (crate "rustversion" "1.0.22" "0vfl70jhv72scd9rfqgr2n11m5i9l1acnk684m2w83w0zbqdx75k"))
(define rust-ryu-1.0.23
  (crate "ryu" "1.0.23" "0zs70sg00l2fb9jwrf6cbkdyscjs53anrvai2hf7npyyfi5blx4p"))
(define rust-same-file-1.0.6
  (crate "same-file" "1.0.6" "00h5j1w87dmhnvbv9l8bic3y7xxsnjmssvifw2ayvgx9mb1ivz4k"))
(define rust-schannel-0.1.29
  (crate "schannel" "0.1.29" "0ffrzz5vf2s3gnzvphgb5gg8fqifvryl07qcf7q3x1scj3jbghci"))
(define rust-schemars-0.8.22
  (crate "schemars" "0.8.22" "05an9nbi18ynyxv1rjmwbg6j08j0496hd64mjggh53mwp3hjmgrz"))
(define rust-schemars-0.9.0
  (crate "schemars" "0.9.0" "0pqncln5hqbzbl2r3yayyr4a82jjf93h2cfxrn0xamvx77wr3lac"))
(define rust-schemars-1.2.1
  (crate "schemars" "1.2.1" "1k16qzpdpy6p9hrh18q2l6cwawxzyqi25f8masa13l0wm8v2zd52"))
(define rust-schemars_derive-0.8.22
  (crate "schemars_derive" "0.8.22" "0kakyzrp5801s4i043l4ilv96lzimnlh01pap958h66n99w6bqij"))
(define rust-scopeguard-1.2.0
  (crate "scopeguard" "1.2.0" "0jcz9sd47zlsgcnm1hdw0664krxwb5gczlif4qngj2aif8vky54l"))
(define rust-secret-service-4.0.0
  (crate "secret-service" "4.0.0" "1m5zkmmhg1wv67g4lr6pqjyqg3yrh3b8bgpw1ykf06qqkbcmmlz4"))
(define rust-security-framework-2.11.1
  (crate "security-framework" "2.11.1" "00ldclwx78dm61v7wkach9lcx76awlrv0fdgjdwch4dmy12j4yw9"))
(define rust-security-framework-3.7.0
  (crate "security-framework" "3.7.0" "07fd0j29j8yczb3hd430vwz784lx9knb5xwbvqna1nbkbivvrx5p"))
(define rust-security-framework-sys-2.17.0
  (crate "security-framework-sys" "2.17.0" "1qr0w0y9iwvmv3hwg653q1igngnc5b74xcf0679cbv23z0fnkqkc"))
(define rust-selectors-0.24.0
  (crate "selectors" "0.24.0" "05il06smqbhf7p18fawm5fd0pmdkysvmyih455lh17cnh20mfdqc"))
(define rust-selectors-0.36.1
  (crate "selectors" "0.36.1" "0370sx9fcb327im4msa0ha5578r95hzwy4bkh443zlwj5b4w1nf5"))
(define rust-semver-1.0.28
  (crate "semver" "1.0.28" "1kaimrpy876bcgi8bfj0qqfxk77zm9iz2zhn1hp9hj685z854y4a"))
(define rust-serde-1.0.228
  (crate "serde" "1.0.228" "17mf4hhjxv5m90g42wmlbc61hdhlm6j9hwfkpcnd72rpgzm993ls"))
(define rust-serde-untagged-0.1.9
  (crate "serde-untagged" "0.1.9" "0n2hdjzas7w949klw1rpfzmpc9sm4sz9sa664jz969id9a5g9ypr"))
(define rust-serde_core-1.0.228
  (crate "serde_core" "1.0.228" "1bb7id2xwx8izq50098s5j2sqrrvk31jbbrjqygyan6ask3qbls1"))
(define rust-serde_derive-1.0.228
  (crate "serde_derive" "1.0.228" "0y8xm7fvmr2kjcd029g9fijpndh8csv5m20g4bd76w8qschg4h6m"))
(define rust-serde_derive_internals-0.29.1
  (crate "serde_derive_internals" "0.29.1" "04g7macx819vbnxhi52cx0nhxi56xlhrybgwybyy7fb9m4h6mlhq"))
(define rust-serde_json-1.0.149
  (crate "serde_json" "1.0.149" "11jdx4vilzrjjd1dpgy67x5lgzr0laplz30dhv75lnf5ffa07z43"))
(define rust-serde_json-1.0.150
  (crate "serde_json" "1.0.150" "1ffgfhy9kndjnrz8lmy95pr758p2zk8dxv6yi99x0vkkni24w0g8"))
(define rust-serde_repr-0.1.20
  (crate "serde_repr" "0.1.20" "1755gss3f6lwvv23pk7fhnjdkjw7609rcgjlr8vjg6791blf6php"))
(define rust-serde_spanned-0.6.9
  (crate "serde_spanned" "0.6.9" "18vmxq6qfrm110caszxrzibjhy2s54n1g5w1bshxq9kjmz7y0hdz"))
(define rust-serde_spanned-1.1.1
  (crate "serde_spanned" "1.1.1" "09jzk7i6wihn3d8i3wi4j4n98ghi93c3b8m8k64nxq0ijn3vaqk6"))
(define rust-serde_urlencoded-0.7.1
  (crate "serde_urlencoded" "0.7.1" "1zgklbdaysj3230xivihs30qi5vkhigg323a9m62k8jwf4a1qjfk"))
(define rust-serde_with-3.18.0
  (crate "serde_with" "3.18.0" "07yhc7g7cmcsv02dxc8338ajcvldmr81li5wsnypv476v3x18m6x"))
(define rust-serde_with-3.21.0
  (crate "serde_with" "3.21.0" "134ydsww9awaga8yvcqj7rn8gpcx75z6sa3waywvirqhfd6cb9bn"))
(define rust-serde_with_macros-3.18.0
  (crate "serde_with_macros" "3.18.0" "0rgb0jsbczmvd4rpmfn1pa0axp5bv6grc4g2axrzxw88wrw8knyk"))
(define rust-serde_with_macros-3.21.0
  (crate "serde_with_macros" "3.21.0" "0q5ndgb7mhdq9cclbawpki5dal28jaxsdnkqq4h7k8drr307pmc4"))
(define rust-serialize-to-javascript-0.1.2
  (crate "serialize-to-javascript" "0.1.2" "1ignjbylp82s9pyhrmb0f26mjzwvpqr6qc6zgjvwv5x10xm6dwq4"))
(define rust-serialize-to-javascript-impl-0.1.2
  (crate "serialize-to-javascript-impl" "0.1.2" "0pdpclvrpw377s64q2vdk9ia8n6nywg6w2w6yw56fvciq0ry0bkp"))
(define rust-servo_arc-0.2.0
  (crate "servo_arc" "0.2.0" "0hgp453zvrj7ry501jhxlcph0hc42gc26zyfwn8ys3yziwps8anm"))
(define rust-servo_arc-0.4.3
  (crate "servo_arc" "0.4.3" "0c2rl0r9x4kbppwlcrd5bnwds612na179im7kb37vqadncxbh3qp"))
(define rust-sha1-0.10.6
  (crate "sha1" "0.10.6" "1fnnxlfg08xhkmwf2ahv634as30l1i3xhlhkvxflmasi5nd85gz3"))
(define rust-sha1-0.11.0
  (crate "sha1" "0.11.0" "05025pf8d8zr2qq5xyh5m3wqls1fn7813gz1mfs7551mk724rk5a"))
(define rust-sha2-0.10.9
  (crate "sha2" "0.10.9" "10xjj843v31ghsksd9sl9y12qfc48157j1xpb8v1ml39jy0psl57"))
(define rust-sha2-0.11.1
  (crate "sha2" "0.11.1" "06ddr559jvwx17d7847l6i1g4hrlwy39j0yimjwwfskxxfdhdms7"))
(define rust-sharded-slab-0.1.7
  (crate "sharded-slab" "0.1.7" "1xipjr4nqsgw34k7a2cgj9zaasl2ds6jwn89886kww93d32a637l"))
(define rust-shared_child-1.1.1
  (crate "shared_child" "1.1.1" "1xykpvl6dyvvprvz5s0kmvd14rkqcv6rwbwyjqcz0l5w6ncjsdhy"))
(define rust-shlex-1.3.0
  (crate "shlex" "1.3.0" "0r1y6bv26c1scpxvhg2cabimrmwgbp4p3wy6syj9n0c4s3q2znhg"))
(define rust-shlex-2.0.1
  (crate "shlex" "2.0.1" "1fjsll1cd7d2bcpdij9kd6w62rpbc7qqzvydvs021vsmr1cxvypq"))
(define rust-sigchld-0.2.4
  (crate "sigchld" "0.2.4" "1cdd7gwb27gd2wnw68gq4b798p1k6ybxz0zwfq0yfm61sgg6w427"))
(define rust-signal-hook-0.3.18
  (crate "signal-hook" "0.3.18" "1qnnbq4g2vixfmlv28i1whkr0hikrf1bsc4xjy2aasj2yina30fq"))
(define rust-signal-hook-registry-1.4.8
  (crate "signal-hook-registry" "1.4.8" "06vc7pmnki6lmxar3z31gkyg9cw7py5x9g7px70gy2hil75nkny4"))
(define rust-simd-adler32-0.3.9
  (crate "simd-adler32" "0.3.9" "0532ysdwcvzyp2bwpk8qz0hijplcdwpssr5gy5r7qwqqy5z5qgbh"))
(define rust-siphasher-0.3.11
  (crate "siphasher" "0.3.11" "03axamhmwsrmh0psdw3gf7c0zc4fyl5yjxfifz9qfka6yhkqid9q"))
(define rust-siphasher-1.0.2
  (crate "siphasher" "1.0.2" "13k7cfbpcm8qgj9p2n8dwg9skv9s0hxk5my30j5chy1p4l78bamj"))
(define rust-siphasher-1.0.3
  (crate "siphasher" "1.0.3" "0jg6l9xyzca5vy4h6gf8r6p4kk84g98fk95pzig1kq6cr4z8grcf"))
(define rust-slab-0.4.12
  (crate "slab" "0.4.12" "1xcwik6s6zbd3lf51kkrcicdq2j4c1fw0yjdai2apy9467i0sy8c"))
(define rust-smallvec-1.15.1
  (crate "smallvec" "1.15.1" "00xxdxxpgyq5vjnpljvkmy99xij5rxgh913ii1v16kzynnivgcb7"))
(define rust-smallvec-1.15.2
  (crate "smallvec" "1.15.2" "143wzbqf6vgapdp2z4qpl0yvlqcn17s8cnk8m28rqly808zsdmlf"))
(define rust-socket2-0.6.3
  (crate "socket2" "0.6.3" "0gkjjcyn69hqhhlh5kl8byk5m0d7hyrp2aqwzbs3d33q208nwxis"))
(define rust-socket2-0.6.4
  (crate "socket2" "0.6.4" "0ldyp5rhba15spwxj1n94xh7sjks1398c3vwpwkxkd1087nwzlaj"))
(define rust-softbuffer-0.4.8
  (crate "softbuffer" "0.4.8" "1hznrcdzhhlr2x84926g28ybnlx649y1anr7mc4m3w5v3sl8vhda"))
(define rust-soup3-0.5.0
  (crate "soup3" "0.5.0" "17sgrkvx5jy6r6pyyhh8cl5mrm96rf0yfl3lqypm24pk815947s7"))
(define rust-soup3-sys-0.5.0
  (crate "soup3-sys" "0.5.0" "09vcp2m0hcddjqsv979d4jnribxp1pvipgjyy4j2z8c0lr88kgky"))
(define rust-specta-2.0.0-rc.25
  (crate "specta" "2.0.0-rc.25" "0l4wvwl67mvfngr4agl84gqqm0xzhcwlhwvxvbqi2w5vph6a7y9q"))
(define rust-specta-macros-2.0.0-rc.25
  (crate "specta-macros" "2.0.0-rc.25" "1fwkal01vyy9qavhdxdwkksds4qxafv5b0lbhhgpz2f2xiblkq9c"))
(define rust-specta-serde-0.0.12
  (crate "specta-serde" "0.0.12" "0a80q1035xz35rhbrnc7lmp812hf7ys5sz7iv2gr9f6xanvp52pf"))
(define rust-specta-typescript-0.0.12
  (crate "specta-typescript" "0.0.12" "1h43w2aia1b97g41m8lbmg3h8lylxzzp7dscgs5jyzsmjpp09533"))
(define rust-stable_deref_trait-1.2.1
  (crate "stable_deref_trait" "1.2.1" "15h5h73ppqyhdhx6ywxfj88azmrpml9gl6zp3pwy2malqa6vxqkc"))
(define rust-static_assertions-1.1.0
  (crate "static_assertions" "1.1.0" "0gsl6xmw10gvn3zs1rv99laj5ig7ylffnh71f9l34js4nr4r7sx2"))
(define rust-string_cache-0.8.9
  (crate "string_cache" "0.8.9" "03z7km2kzlwiv2r2qifq5riv4g8phazwng9wnvs3py3lzainnxxz"))
(define rust-string_cache-0.9.0
  (crate "string_cache" "0.9.0" "008rwf8gd1xhwr523r5zzzgypgkfmrz6l3wwh7r2k9w5qzw9d1d1"))
(define rust-string_cache_codegen-0.5.4
  (crate "string_cache_codegen" "0.5.4" "181ir4d6y053s1kka2idpjx5g9d9jgll6fy517jhzzpi2n3r44f7"))
(define rust-string_cache_codegen-0.6.1
  (crate "string_cache_codegen" "0.6.1" "0scvya8dsfard2r8m7pb2cjnar312jc9g165fsghacdjdpj3amjq"))
(define rust-strsim-0.11.1
  (crate "strsim" "0.11.1" "0kzvqlw8hxqb7y598w1s0hxlnmi84sg5vsipp3yg5na5d1rvba3x"))
(define rust-subtle-2.6.1
  (crate "subtle" "2.6.1" "14ijxaymghbl1p0wql9cib5zlwiina7kall6w7g89csprkgbvhhk"))
(define rust-swift-rs-1.0.7
  (crate "swift-rs" "1.0.7" "1my4s3w5a5nvlpnzjnfi38snn7spgfn2m0yarzym2bc55s7cjms0"))
(define rust-symlink-0.1.0
  (crate "symlink" "0.1.0" "02h1i0b81mxb4vns4xrvrfibpcvs7jqqav8p3yilwik8cv73r5x7"))
(define rust-syn-1.0.109
  (crate "syn" "1.0.109" "0ds2if4600bd59wsv7jjgfkayfzy3hnazs394kz6zdkmna8l3dkj"))
(define rust-syn-2.0.117
  (crate "syn" "2.0.117" "16cv7c0wbn8amxc54n4w15kxlx5ypdmla8s0gxr2l7bv7s0bhrg6"))
(define rust-syn-3.0.6
  (crate "syn" "3.0.6" "1vmw7s58rzrs926nv5m06x7qbgswm1aa9iw3s1bj5var47kyi4w5"))
(define rust-sync_wrapper-1.0.2
  (crate "sync_wrapper" "1.0.2" "0qvjyasd6w18mjg5xlaq5jgy84jsjfsvmnn12c13gypxbv75dwhb"))
(define rust-synstructure-0.13.2
  (crate "synstructure" "0.13.2" "1lh9lx3r3jb18f8sbj29am5hm9jymvbwh6jb1izsnnxgvgrp12kj"))
(define rust-system-configuration-0.7.0
  (crate "system-configuration" "0.7.0" "12rwilylzc625qnxl30h5kf8wj5ka61zjrwpmb034cd0mc6ksgx1"))
(define rust-system-configuration-sys-0.6.0
  (crate "system-configuration-sys" "0.6.0" "1i5sqrmgy58l4704hibjbl36hclddglh73fb3wx95jnmrq81n7cf"))
(define rust-system-deps-6.2.2
  (crate "system-deps" "6.2.2" "0j93ryw031n3h8b0nfpj5xwh3ify636xmv8kxianvlyyipmkbrd3"))
(define rust-tao-0.34.8
  (crate "tao" "0.34.8" "086cwxy0xq4qgmazlw8fxbz2n0s189yanzscx8mci8rdbzsys0wi"))
(define rust-tao-0.35.3
  (crate "tao" "0.35.3" "1afl7mfsgl0zdz41w7i03fyi0w6aik2hls9ld936k1pnmi3k1jfi"))
(define rust-tao-macros-0.1.3
  (crate "tao-macros" "0.1.3" "1zbx0ifpn6xi4sc6vp7wq0sbpgrdwr0cm2xbisr7vh9aigmnpqgl"))
(define rust-tar-0.4.45
  (crate "tar" "0.4.45" "0wq90hif25348zrvmk88q01g8aj8v8pla7f1vxgsf7x2frj2ls92"))
(define rust-target-lexicon-0.12.16
  (crate "target-lexicon" "0.12.16" "1cg3bnx1gdkdr5hac1hzxy64fhw4g7dqkd0n3dxy5lfngpr1mi31"))
(define rust-tauri-2.10.3
  (crate "tauri" "2.10.3" "0bdsy371wvahgrzwmpsr6ilz67hzwdshyrflnpswla4hzc0cqxys"))
(define rust-tauri-2.11.2
  (crate "tauri" "2.11.2" "0a6cyhar0cry58xbi9yn9qkiz5xv25zglyhpy62msdyggach8x23"))
(define rust-tauri-build-2.5.6
  (crate "tauri-build" "2.5.6" "0kgx17gbm0awpaww20snh1bvgn0llvr2f8zsqzhshmxz3l6rkg2b"))
(define rust-tauri-build-2.6.2
  (crate "tauri-build" "2.6.2" "1isinikimq4gfmp0i1q4xx5d0vnipr9504jf9sjijff2bw2zk8aa"))
(define rust-tauri-codegen-2.5.5
  (crate "tauri-codegen" "2.5.5" "0abdpp288z1m1agd4vci8wkxh4w6hqjj9xv9s7awaxyrmxv498nl"))
(define rust-tauri-codegen-2.6.2
  (crate "tauri-codegen" "2.6.2" "1schiyrirpiycjd6bc6x40vfdx26qkidmrvq826a69d052ak3874"))
(define rust-tauri-macros-2.5.5
  (crate "tauri-macros" "2.5.5" "1rrxqg889crx812fg8p52699jg7js7f402iznzmzznnsk2d396yk"))
(define rust-tauri-macros-2.6.2
  (crate "tauri-macros" "2.6.2" "0929xvdib0ci1ybhxvanp8xib85f5wfjacavvbvd48bci7iv8v5f"))
(define rust-tauri-plugin-2.5.4
  (crate "tauri-plugin" "2.5.4" "1anl1hlwkhx5z247wrakh5y6lbb4kbdcs1ihazxl1f87r58pvpnx"))
(define rust-tauri-plugin-2.6.2
  (crate "tauri-plugin" "2.6.2" "0vls8q5w6xjp33qaq8qavyqcsl0q7akl0qar07ywsdafx34sn9p1"))
(define rust-tauri-plugin-dialog-2.7.0
  (crate "tauri-plugin-dialog" "2.7.0" "028qm5nrb3k2g4pqlfmsr8kp8y8lmc2zkf68dja93qssr5843ym1"))
(define rust-tauri-plugin-dialog-2.7.1
  (crate "tauri-plugin-dialog" "2.7.1" "114qmigimg3swshfp4a72rwr6i8wl6xc75l1ldqyax0yfyxim635"))
(define rust-tauri-plugin-fs-2.5.0
  (crate "tauri-plugin-fs" "2.5.0" "1n0yhwwrnsrrsiq8frhnczmc14k2qcaiczjhyj1hcgcznwlfrq9n"))
(define rust-tauri-plugin-fs-2.5.1
  (crate "tauri-plugin-fs" "2.5.1" "0wgkx141aaswff5bpq2liws8sdixx35x2hibd81hrjhs29sc5v5p"))
(define rust-tauri-plugin-global-shortcut-2.3.2
  (crate "tauri-plugin-global-shortcut" "2.3.2" "0axx8dc475v5dvqiqngan9nndm6c9bf8c36scbcrrh1na569zpdl"))
(define rust-tauri-plugin-notification-2.3.3
  (crate "tauri-plugin-notification" "2.3.3" "1k4ls5bn64pj2wx03yl2kds71z9yvwgj1n22f8gvs18iyigjrz01"))
(define rust-tauri-plugin-opener-2.5.4
  (crate "tauri-plugin-opener" "2.5.4" "0agdxv65chbigppcv0xfzb29njwjzpiif92fl29vgrnw9shvxq8p"))
(define rust-tauri-plugin-shell-2.3.5
  (crate "tauri-plugin-shell" "2.3.5" "0fy7s32fwffnbsn3xjvris3ajnbshlh2rfr2vzcfvcdswbwxnmw4"))
(define rust-tauri-plugin-single-instance-2.4.4
  (crate "tauri-plugin-single-instance" "2.4.4" "1qdinqaqvc398yibd0sa1m38kfrwb3qnssmbkfv72l1a85fcpl2w"))
(define rust-tauri-plugin-window-state-2.4.1
  (crate "tauri-plugin-window-state" "2.4.1" "0157y4p6v6wrhp7d0fjjzcy2mwd2rkij2gim2n6l0hj1w48ncwvk"))
(define rust-tauri-runtime-2.10.1
  (crate "tauri-runtime" "2.10.1" "18jy8k2apgkxinylzg04jnb353pm9rj15x57dv6hivcp6addf9i8"))
(define rust-tauri-runtime-2.11.2
  (crate "tauri-runtime" "2.11.2" "1vr9y76n2y8bsykfrrk19q42bqgs4gh75wz2dym7x0682rqjs8j8"))
(define rust-tauri-runtime-wry-2.10.1
  (crate "tauri-runtime-wry" "2.10.1" "17kzpzg9r33qvg89cfy3l512f09n6xhckmlhv3ypblh1z3ka47p1"))
(define rust-tauri-runtime-wry-2.11.2
  (crate "tauri-runtime-wry" "2.11.2" "1nbcbx0hz7qpn5nzjhya9a8pcl11r8aikr8gin77mcpccgp4jf5q"))
(define rust-tauri-utils-2.8.3
  (crate "tauri-utils" "2.8.3" "0zamwjnb6phsj10pm7060gzsf39vfdv7yx5mflznbwra7ac1z6i1"))
(define rust-tauri-utils-2.9.2
  (crate "tauri-utils" "2.9.2" "15dap6xnglb06c93qjid3vq8glq14jyb2mkcisbk2xkhkbgpj8q9"))
(define rust-tauri-winres-0.3.6
  (crate "tauri-winres" "0.3.6" "1dnld4gpnb2k9p7id2ksl3wfrnqmbm5q77nj1m1gx2w5d1fd8rfc"))
(define rust-tauri-winrt-notification-0.7.3
  (crate "tauri-winrt-notification" "0.7.3" "1pmah3lbz2igsch2bxwvz3s3ihyqj9j71bj85zy8abiqf3373l4y"))
(define rust-tempfile-3.27.0
  (crate "tempfile" "3.27.0" "1gblhnyfjsbg9wjg194n89wrzah7jy3yzgnyzhp56f3v9jd7wj9j"))
(define rust-tendril-0.4.3
  (crate "tendril" "0.4.3" "1c3vip59sqwxn148i714nmkrvjzbk7105vj0h92s6r64bw614jnj"))
(define rust-tendril-0.5.0
  (crate "tendril" "0.5.0" "090dcvslanahwjnm4ihggjiv7fc82gir9c24nps319fmd71hyyf4"))
(define rust-thiserror-1.0.69
  (crate "thiserror" "1.0.69" "0lizjay08agcr5hs9yfzzj6axs53a2rgx070a1dsi3jpkcrzbamn"))
(define rust-thiserror-2.0.18
  (crate "thiserror" "2.0.18" "1i7vcmw9900bvsmay7mww04ahahab7wmr8s925xc083rpjybb222"))
(define rust-thiserror-impl-1.0.69
  (crate "thiserror-impl" "1.0.69" "1h84fmn2nai41cxbhk6pqf46bxqq1b344v8yz089w1chzi76rvjg"))
(define rust-thiserror-impl-2.0.18
  (crate "thiserror-impl" "2.0.18" "1mf1vrbbimj1g6dvhdgzjmn6q09yflz2b92zs1j9n3k7cxzyxi7b"))
(define rust-thread_local-1.1.10
  (crate "thread_local" "1.1.10" "0w20g2pfdcp8pz3gds0bzksv6mxk802szca8qlr3701jdm69rn8s"))
(define rust-time-0.3.47
  (crate "time" "0.3.47" "0b7g9ly2iabrlgizliz6v5x23yq5d6bpp0mqz6407z1s526d8fvl"))
(define rust-time-0.3.49
  (crate "time" "0.3.49" "0sc4dgw6g187gvz5qj9iqqk2ashqzvdwi664b2183gbvsk1566ki"))
(define rust-time-core-0.1.8
  (crate "time-core" "0.1.8" "1jidl426mw48i7hjj4hs9vxgd9lwqq4vyalm4q8d7y4iwz7y353n"))
(define rust-time-core-0.1.9
  (crate "time-core" "0.1.9" "028ix0ax7ixp1h1k5zsqwgw85w6y1q32irslma7ci6ddd5kr074y"))
(define rust-time-macros-0.2.27
  (crate "time-macros" "0.2.27" "058ja265waq275wxvnfwavbz9r1hd4dgwpfn7a1a9a70l32y8w1f"))
(define rust-time-macros-0.2.29
  (crate "time-macros" "0.2.29" "0zf1ycfikg93ijf00qnprk801khqnqqga1zp0adbp73sfaim5iki"))
(define rust-tinystr-0.8.3
  (crate "tinystr" "0.8.3" "0vfr8x285w6zsqhna0a9jyhylwiafb2kc8pj2qaqaahw48236cn8"))
(define rust-tinyvec-1.11.0
  (crate "tinyvec" "1.11.0" "1wvycrghzmaysnw34kzwnf0mfx6r75045s24r214wnnjadqfcq9y"))
(define rust-tinyvec_macros-0.1.1
  (crate "tinyvec_macros" "0.1.1" "081gag86208sc3y6sdkshgw3vysm5d34p431dzw0bshz66ncng0z"))
(define rust-tokio-1.52.1
  (crate "tokio" "1.52.1" "1imw1dkkv38p66i33m5hsyk3d6prsbyrayjvqhndjvz89ybywzdn"))
(define rust-tokio-1.54.1
  (crate "tokio" "1.54.1" "18wn0c3yvy6ld8yis0fw6rqkc4rwnmv5mav4fan6zljqa8jx6bxm"))
(define rust-tokio-macros-2.7.0
  (crate "tokio-macros" "2.7.0" "15m4f37mdafs0gg36sh0rskm1i768lb7zmp8bw67kaxr3avnqniq"))
(define rust-tokio-native-tls-0.3.1
  (crate "tokio-native-tls" "0.3.1" "1wkfg6zn85zckmv4im7mv20ca6b1vmlib5xwz9p7g19wjfmpdbmv"))
(define rust-tokio-rustls-0.26.4
  (crate "tokio-rustls" "0.26.4" "0qggwknz9w4bbsv1z158hlnpkm97j3w8v31586jipn99byaala8p"))
(define rust-tokio-tungstenite-0.24.0
  (crate "tokio-tungstenite" "0.24.0" "1nfw1i6yy120a14h1xagd4f31k3g1mz4rdxpvgh77jcd4i7ggigd"))
(define rust-tokio-util-0.7.18
  (crate "tokio-util" "0.7.18" "1600rd47pylwn7cap1k7s5nvdaa9j7w8kqigzp1qy7mh0p4cxscs"))
(define rust-toml-0.8.2
  (crate "toml" "0.8.2" "0g9ysjaqvm2mv8q85xpqfn7hi710hj24sd56k49wyddvvyq8lp8q"))
(define rust-toml-0.9.12-spec-1.1.0
  (crate "toml" "0.9.12+spec-1.1.0" "0qwqbrymqn88mg2yqyq3rj52z6p20448z0jxdbpjsbpwg5g894ng"))
(define rust-toml-1.1.2-spec-1.1.0
  (crate "toml" "1.1.2+spec-1.1.0" "1vpggpamqhw4852kic7465zsidczsla06wz6friqkkfbhigd3ww1"))
(define rust-toml_datetime-0.6.3
  (crate "toml_datetime" "0.6.3" "0jsy7v8bdvmzsci6imj8fzgd255fmy5fzp6zsri14yrry7i77nkw"))
(define rust-toml_datetime-0.7.5-spec-1.1.0
  (crate "toml_datetime" "0.7.5+spec-1.1.0" "0iqkgvgsxmszpai53dbip7sf2igic39s4dby29dbqf1h9bnwzqcj"))
(define rust-toml_datetime-1.1.1-spec-1.1.0
  (crate "toml_datetime" "1.1.1+spec-1.1.0" "1mws2mkkf46l7inn77azhm0vdwxngv9vsbhbl0ah33p2c9gzcr9i"))
(define rust-toml_edit-0.19.15
  (crate "toml_edit" "0.19.15" "08bl7rp5g6jwmfpad9s8jpw8wjrciadpnbaswgywpr9hv9qbfnqv"))
(define rust-toml_edit-0.20.2
  (crate "toml_edit" "0.20.2" "0f7k5svmxw98fhi28jpcyv7ldr2s3c867pjbji65bdxjpd44svir"))
(define rust-toml_edit-0.25.11-spec-1.1.0
  (crate "toml_edit" "0.25.11+spec-1.1.0" "0awzffbkx33v9x4h19b5mfrwp3sn4ifr16y58sbk6j6l5v9c8n8b"))
(define rust-toml_edit-0.25.12-spec-1.1.0
  (crate "toml_edit" "0.25.12+spec-1.1.0" "1mx5paq837rjw7w51zprrjynk1vaig9yzxfqz9ac79jmd7f3w5fj"))
(define rust-toml_parser-1.1.2-spec-1.1.0
  (crate "toml_parser" "1.1.2+spec-1.1.0" "09kmzc55a0j21whm290wlf5a8b18a0qc87a1s8sncrckc6wfkax2"))
(define rust-toml_writer-1.1.1-spec-1.1.0
  (crate "toml_writer" "1.1.1+spec-1.1.0" "1nwjhvvrxz8f4ck1qi4xcz2x9qhpci37nrknhxxf9sqk22dsyvbm"))
(define rust-tower-0.5.3
  (crate "tower" "0.5.3" "1m5i3a2z1sgs8nnz1hgfq2nr4clpdmizlp1d9qsg358ma5iyzrgb"))
(define rust-tower-http-0.6.11
  (crate "tower-http" "0.6.11" "0h08wjgs3hwnq11iwwzlmnabn1h4cl0fzd48svaccvqffkiggz2c"))
(define rust-tower-http-0.6.8
  (crate "tower-http" "0.6.8" "1y514jwzbyrmrkbaajpwmss4rg0mak82k16d6588w9ncaffmbrnl"))
(define rust-tower-layer-0.3.3
  (crate "tower-layer" "0.3.3" "03kq92fdzxin51w8iqix06dcfgydyvx7yr6izjq0p626v9n2l70j"))
(define rust-tower-service-0.3.3
  (crate "tower-service" "0.3.3" "1hzfkvkci33ra94xjx64vv3pp0sq346w06fpkcdwjcid7zhvdycd"))
(define rust-tracing-0.1.44
  (crate "tracing" "0.1.44" "006ilqkg1lmfdh3xhg3z762izfwmxcvz0w7m4qx2qajbz9i1drv3"))
(define rust-tracing-appender-0.2.5
  (crate "tracing-appender" "0.2.5" "0g4a6q5s3wafid5lqw1ljzvh1nhk3a4zmb627fxv96dr7qcqc1h5"))
(define rust-tracing-attributes-0.1.31
  (crate "tracing-attributes" "0.1.31" "1np8d77shfvz0n7camx2bsf1qw0zg331lra0hxb4cdwnxjjwz43l"))
(define rust-tracing-core-0.1.36
  (crate "tracing-core" "0.1.36" "16mpbz6p8vd6j7sf925k9k8wzvm9vdfsjbynbmaxxyq6v7wwm5yv"))
(define rust-tracing-log-0.2.0
  (crate "tracing-log" "0.2.0" "1hs77z026k730ij1a9dhahzrl0s073gfa2hm5p0fbl0b80gmz1gf"))
(define rust-tracing-subscriber-0.3.23
  (crate "tracing-subscriber" "0.3.23" "06fkr0qhggvrs861d7f74pn3i3a10h5jsp4n70jj9ys5b675fzyb"))
(define rust-tray-icon-0.21.3
  (crate "tray-icon" "0.21.3" "0378wl43dgllxivqxg776vb522jj3dn3bmn45w375c6f8fhmms55"))
(define rust-tray-icon-0.23.1
  (crate "tray-icon" "0.23.1" "0wq7dhhqajm5hwhdlc5sbkgi8wz1700430zjipp8agjqh06vpv8m"))
(define rust-try-lock-0.2.5
  (crate "try-lock" "0.2.5" "0jqijrrvm1pyq34zn1jmy2vihd4jcrjlvsh4alkjahhssjnsn8g4"))
(define rust-tungstenite-0.24.0
  (crate "tungstenite" "0.24.0" "12nsxnxazk4nisgsqpywi6za0hsbc2rd15r1scb5pag7dqvbir8q"))
(define rust-typed-path-0.12.3
  (crate "typed-path" "0.12.3" "03k051dafrnyg3lbm4c85zg0mpfhbn6l9aq4ryq8yyy8h2dzha4f"))
(define rust-typeid-1.0.3
  (crate "typeid" "1.0.3" "0727ypay2p6mlw72gz3yxkqayzdmjckw46sxqpaj08v0b0r64zdw"))
(define rust-typenum-1.20.0
  (crate "typenum" "1.20.0" "1pj35y6q11d3y55gdl6g1h2dfhmybjming0jdi9bh0bpnqm11kj0"))
(define rust-typenum-1.20.1
  (crate "typenum" "1.20.1" "086s9ly0906kw5yw41249fba97w5zfxf03pyfwdkffvcprqfixdn"))
(define rust-uds_windows-1.2.1
  (crate "uds_windows" "1.2.1" "0vidqwwfgn8wyzvbxiqil787b4wyqjia50zpdbbjqx7n8wlgpxpj"))
(define rust-unic-char-property-0.9.0
  (crate "unic-char-property" "0.9.0" "08g21dn3wwix3ycfl0vrbahn0835nv2q3swm8wms0vwvgm07mid8"))
(define rust-unic-char-range-0.9.0
  (crate "unic-char-range" "0.9.0" "1g0z7iwvjhqspi6194zsff8vy6i3921hpqcrp3v1813hbwnh5603"))
(define rust-unic-common-0.9.0
  (crate "unic-common" "0.9.0" "1g1mm954m0zr497dl4kx3vr09yaly290zs33bbl4wrbaba1gzmw0"))
(define rust-unic-ucd-ident-0.9.0
  (crate "unic-ucd-ident" "0.9.0" "11v9mfyl9rqnvd9a8hgmbgnzyxd3lcx0dkv7klhskjl10dya6c72"))
(define rust-unic-ucd-version-0.9.0
  (crate "unic-ucd-version" "0.9.0" "1i5hnzpfnxkp4ijfk8kvhpvj84bij575ybqx1b6hyigy6wi2zgcn"))
(define rust-unicase-2.9.0
  (crate "unicase" "2.9.0" "0hh1wrfd7807mfph2q67jsxqgw8hm82xg2fb8ln8cvblkwxbri6v"))
(define rust-unicode-ident-1.0.24
  (crate "unicode-ident" "1.0.24" "0xfs8y1g7syl2iykji8zk5hgfi5jw819f5zsrbaxmlzwsly33r76"))
(define rust-unicode-segmentation-1.13.2
  (crate "unicode-segmentation" "1.13.2" "135a26m4a0wj319gcw28j6a5aqvz00jmgwgmcs6szgxjf942facn"))
(define rust-unicode-segmentation-1.13.3
  (crate "unicode-segmentation" "1.13.3" "1a47zaq83p386r3baq4m018xd5q4q0grdg56i1x042dzn71x7xf6"))
(define rust-unicode-xid-0.2.6
  (crate "unicode-xid" "0.2.6" "0lzqaky89fq0bcrh6jj6bhlz37scfd8c7dsj5dq7y32if56c1hgb"))
(define rust-untrusted-0.9.0
  (crate "untrusted" "0.9.0" "1ha7ib98vkc538x0z60gfn0fc5whqdd85mb87dvisdcaifi6vjwf"))
(define rust-url-2.5.8
  (crate "url" "2.5.8" "1v8f7nx3hpr1qh76if0a04sj08k86amsq4h8cvpw6wvk76jahrzz"))
(define rust-urlpattern-0.3.0
  (crate "urlpattern" "0.3.0" "0vds6wyawgap069q34wl0yf8w5qdmpi6r2ffxv10nid1787d7b3h"))
(define rust-utf-8-0.7.6
  (crate "utf-8" "0.7.6" "1a9ns3fvgird0snjkd3wbdhwd3zdpc2h5gpyybrfr6ra5pkqxk09"))
(define rust-utf8_iter-1.0.4
  (crate "utf8_iter" "1.0.4" "1gmna9flnj8dbyd8ba17zigrp9c4c3zclngf5lnb5yvz1ri41hdn"))
(define rust-uuid-1.23.1
  (crate "uuid" "1.23.1" "0xlwg23rmsfl3gx98qsyzpl24pf4bs9wi3mqx5c6i319hyb4mmyx"))
(define rust-uuid-1.23.3
  (crate "uuid" "1.23.3" "1drddl03gi12vl1s3l2h371dw39plhn9wappp00v707g7h96nk8l"))
(define rust-valuable-0.1.1
  (crate "valuable" "0.1.1" "0r9srp55v7g27s5bg7a2m095fzckrcdca5maih6dy9bay6fflwxs"))
(define rust-vcpkg-0.2.15
  (crate "vcpkg" "0.2.15" "09i4nf5y8lig6xgj3f7fyrvzd3nlaw4znrihw8psidvv5yk4xkdc"))
(define rust-version-compare-0.2.1
  (crate "version-compare" "0.2.1" "03nziqxwnxlizl42cwsx33vi5xd2cf2jnszhh9rzay7g6xl8bhh3"))
(define rust-version_check-0.9.5
  (crate "version_check" "0.9.5" "0nhhi4i5x89gm911azqbn7avs9mdacw2i3vcz3cnmz3mv4rqz4hb"))
(define rust-vswhom-0.1.0
  (crate "vswhom" "0.1.0" "12v0fjjzxdc3y5c0lcwycfhphz7zf2s06hl5krwhawah0xzrp5xy"))
(define rust-vswhom-sys-0.1.3
  (crate "vswhom-sys" "0.1.3" "0l0i4fijapsybmfckfqh53yqxsg0bm5ikja6vz8ngw0zpm67w1pv"))
(define rust-walkdir-2.5.0
  (crate "walkdir" "2.5.0" "0jsy7a710qv8gld5957ybrnc07gavppp963gs32xk4ag8130jy99"))
(define rust-want-0.3.1
  (crate "want" "0.3.1" "03hbfrnvqqdchb5kgxyavb9jabwza0dmh2vw5kg0dq8rxl57d9xz"))
(define rust-wasi-0.11.1-wasi-snapshot-preview1
  (crate "wasi" "0.11.1+wasi-snapshot-preview1" "0jx49r7nbkbhyfrfyhz0bm4817yrnxgd3jiwwwfv0zl439jyrwyc"))
(define rust-wasi-0.9.0-wasi-snapshot-preview1
  (crate "wasi" "0.9.0+wasi-snapshot-preview1" "06g5v3vrdapfzvfq662cij7v8a1flwr2my45nnncdv2galrdzkfc"))
(define rust-wasip2-1.0.3-wasi-0.2.9
  (crate "wasip2" "1.0.3+wasi-0.2.9" "1mi3w855dz99xzjqc4aa8c9q5b6z1y5c963pkk4cvmr6vdr4c1i0"))
(define rust-wasip2-1.0.4-wasi-0.2.12
  (crate "wasip2" "1.0.4+wasi-0.2.12" "11wl7lqwq4pbmlmzr6n7bwz0hzy1z6sxc4554bkmrr86w4vznzmn"))
(define rust-wasip3-0.4.0-wasi-0.3.0-rc-2026-01-06
  (crate "wasip3" "0.4.0+wasi-0.3.0-rc-2026-01-06" "19dc8p0y2mfrvgk3qw3c3240nfbylv22mvyxz84dqpgai2zzha2l"))
(define rust-wasm-bindgen-0.2.120
  (crate "wasm-bindgen" "0.2.120" "1cax9wy1n67sa2m16ia72lsxdrc5pzcv47psxp4p833yp3cvclnz"))
(define rust-wasm-bindgen-0.2.125
  (crate "wasm-bindgen" "0.2.125" "06nakz7nfy0ymyp7a27wfbjwx69659i12117hkgddkiv2iwkznwd"))
(define rust-wasm-bindgen-futures-0.4.70
  (crate "wasm-bindgen-futures" "0.4.70" "1130a64yig0p10mk7rnq5l2jpwglbyxpnqg6h0nlqwzcmir4i4xg"))
(define rust-wasm-bindgen-futures-0.4.75
  (crate "wasm-bindgen-futures" "0.4.75" "104jssshr6cm5hmkn6c66mbkyxgaaphng6c17g0dmj7jhk918fsh"))
(define rust-wasm-bindgen-macro-0.2.120
  (crate "wasm-bindgen-macro" "0.2.120" "00xixpydzjd6y9knwdsrsiff6wi1ddszb1fa9bk25csz94gh9cbq"))
(define rust-wasm-bindgen-macro-0.2.125
  (crate "wasm-bindgen-macro" "0.2.125" "0g9w68dwcs4ylm5kxf7schi0kjdfarhc9qlnf8arxc9zn62a28af"))
(define rust-wasm-bindgen-macro-support-0.2.120
  (crate "wasm-bindgen-macro-support" "0.2.120" "0h8v5aphaaq155fzz2d312zrxbka1x6lsvb8mhc8m60n0kr0zkcx"))
(define rust-wasm-bindgen-macro-support-0.2.125
  (crate "wasm-bindgen-macro-support" "0.2.125" "1gayzdx5iwl8gllh7ys79wg9cf4iyasl9hrzzhh5m4xx6nfgvkpy"))
(define rust-wasm-bindgen-shared-0.2.120
  (crate "wasm-bindgen-shared" "0.2.120" "1sjrac4f4j5pgw42mxadq9v42f0bji1a2rcksrbnrwgbh8y7nxa9"))
(define rust-wasm-bindgen-shared-0.2.125
  (crate "wasm-bindgen-shared" "0.2.125" "07w7fy5qa14ys3p8v2p84h98yqinw713smibz9v7apcspd29x4r3"))
(define rust-wasm-encoder-0.244.0
  (crate "wasm-encoder" "0.244.0" "06c35kv4h42vk3k51xjz1x6hn3mqwfswycmr6ziky033zvr6a04r"))
(define rust-wasm-metadata-0.244.0
  (crate "wasm-metadata" "0.244.0" "02f9dhlnryd2l7zf03whlxai5sv26x4spfibjdvc3g9gd8z3a3mv"))
(define rust-wasm-streams-0.4.2
  (crate "wasm-streams" "0.4.2" "0rddn007hp6k2cm91mm9y33n79b0jxv0c3znzszcvv67hn6ks18m"))
(define rust-wasm-streams-0.5.0
  (crate "wasm-streams" "0.5.0" "1fqbcx33w8ys5i5dv3p28a82g4yiclmhn80fcfp137kwa7vc87lx"))
(define rust-wasmparser-0.244.0
  (crate "wasmparser" "0.244.0" "1zi821hrlsxfhn39nqpmgzc0wk7ax3dv6vrs5cw6kb0v5v3hgf27"))
(define rust-web-sys-0.3.102
  (crate "web-sys" "0.3.102" "0786aybrnwsgdmcynhc2k5ii291a02rq9zk054j35csyvxr0lhx6"))
(define rust-web-sys-0.3.97
  (crate "web-sys" "0.3.97" "00knh8cizgb01bmh362f3f19b11f8zl1y3gj6h47pk95233vmb9f"))
(define rust-web_atoms-0.2.4
  (crate "web_atoms" "0.2.4" "0f65zxzg1g8xra01kg7im614s11nyhpkl3i5zls1ipqmz3pgdkyp"))
(define rust-webkit2gtk-2.0.2
  (crate "webkit2gtk" "2.0.2" "14s7zkrdcqayjz443ia5ba0y86j6i3ghhr40mwpgnc1m058720m1"))
(define rust-webkit2gtk-sys-2.0.2
  (crate "webkit2gtk-sys" "2.0.2" "19affdnf0x698fcjxfzxb59mdm635q59d5gnzw9gw3ggq9jmysli"))
(define rust-webview2-com-0.38.2
  (crate "webview2-com" "0.38.2" "0sn9bdm9mvfq3j3bbmssigh3s4wyd8p88m2f8i5cacsvg8x28c3i"))
(define rust-webview2-com-macros-0.8.1
  (crate "webview2-com-macros" "0.8.1" "0m4vkg7pgcwv3743ka9hgp3ywszrwv6x8g425dxkck4inv0j3ab7"))
(define rust-webview2-com-sys-0.38.2
  (crate "webview2-com-sys" "0.38.2" "175zmj5w86z6k6f6gbavz8pil9d58xa280hp55ykfwnpzz7kc4rq"))
(define rust-winapi-0.3.9
  (crate "winapi" "0.3.9" "06gl025x418lchw1wxj64ycr7gha83m44cjr5sarhynd9xkrm0sw"))
(define rust-winapi-i686-pc-windows-gnu-0.4.0
  (crate "winapi-i686-pc-windows-gnu" "0.4.0" "1dmpa6mvcvzz16zg6d5vrfy4bxgg541wxrcip7cnshi06v38ffxc"))
(define rust-winapi-util-0.1.11
  (crate "winapi-util" "0.1.11" "08hdl7mkll7pz8whg869h58c1r9y7in0w0pk8fm24qc77k0b39y2"))
(define rust-winapi-x86_64-pc-windows-gnu-0.4.0
  (crate "winapi-x86_64-pc-windows-gnu" "0.4.0" "0gqq64czqb64kskjryj8isp62m2sgvx25yyj3kpc2myh85w24bki"))
(define rust-window-vibrancy-0.6.0
  (crate "window-vibrancy" "0.6.0" "174srq6qy9a4qiwcq1kk5r1wmab1vp4ykl4g4pr654rz3yiwbgnr"))
(define rust-windows-0.61.3
  (crate "windows" "0.61.3" "14v8dln7i4ccskd8danzri22bkjkbmgzh284j3vaxhd4cykx7awv"))
(define rust-windows-collections-0.2.0
  (crate "windows-collections" "0.2.0" "1s65anr609qvsjga7w971p6iq964h87670dkfqfypnfgwnswxviv"))
(define rust-windows-core-0.61.2
  (crate "windows-core" "0.61.2" "1qsa3iw14wk4ngfl7ipcvdf9xyq456ms7cx2i9iwf406p7fx7zf0"))
(define rust-windows-core-0.62.2
  (crate "windows-core" "0.62.2" "1swxpv1a8qvn3bkxv8cn663238h2jccq35ff3nsj61jdsca3ms5q"))
(define rust-windows-future-0.2.1
  (crate "windows-future" "0.2.1" "13mdzcdn51ckpzp3frb8glnmkyjr1c30ym9wnzj9zc97hkll2spw"))
(define rust-windows-implement-0.60.2
  (crate "windows-implement" "0.60.2" "1psxhmklzcf3wjs4b8qb42qb6znvc142cb5pa74rsyxm1822wgh5"))
(define rust-windows-interface-0.59.3
  (crate "windows-interface" "0.59.3" "0n73cwrn4247d0axrk7gjp08p34x1723483jxjxjdfkh4m56qc9z"))
(define rust-windows-link-0.1.3
  (crate "windows-link" "0.1.3" "12kr1p46dbhpijr4zbwr2spfgq8i8c5x55mvvfmyl96m01cx4sjy"))
(define rust-windows-link-0.2.1
  (crate "windows-link" "0.2.1" "1rag186yfr3xx7piv5rg8b6im2dwcf8zldiflvb22xbzwli5507h"))
(define rust-windows-numerics-0.2.0
  (crate "windows-numerics" "0.2.0" "1cf2j8nbqf0hqqa7chnyid91wxsl2m131kn0vl3mqk3c0rlayl4i"))
(define rust-windows-registry-0.6.1
  (crate "windows-registry" "0.6.1" "082p7l615qk8a4g8g15yipc5lghga6cgfhm74wm7zknwzgvjnx82"))
(define rust-windows-result-0.3.4
  (crate "windows-result" "0.3.4" "1il60l6idrc6hqsij0cal0mgva6n3w6gq4ziban8wv6c6b9jpx2n"))
(define rust-windows-result-0.4.1
  (crate "windows-result" "0.4.1" "1d9yhmrmmfqh56zlj751s5wfm9a2aa7az9rd7nn5027nxa4zm0bp"))
(define rust-windows-strings-0.4.2
  (crate "windows-strings" "0.4.2" "0mrv3plibkla4v5kaakc2rfksdd0b14plcmidhbkcfqc78zwkrjn"))
(define rust-windows-strings-0.5.1
  (crate "windows-strings" "0.5.1" "14bhng9jqv4fyl7lqjz3az7vzh8pw0w4am49fsqgcz67d67x0dvq"))
(define rust-windows-sys-0.45.0
  (crate "windows-sys" "0.45.0" "1l36bcqm4g89pknfp8r9rl1w4bn017q6a8qlx8viv0xjxzjkna3m"))
(define rust-windows-sys-0.48.0
  (crate "windows-sys" "0.48.0" "1aan23v5gs7gya1lc46hqn9mdh8yph3fhxmhxlw36pn6pqc28zb7"))
(define rust-windows-sys-0.52.0
  (crate "windows-sys" "0.52.0" "0gd3v4ji88490zgb6b5mq5zgbvwv7zx1ibn8v3x83rwcdbryaar8"))
(define rust-windows-sys-0.59.0
  (crate "windows-sys" "0.59.0" "0fw5672ziw8b3zpmnbp9pdv1famk74f1l9fcbc3zsrzdg56vqf0y"))
(define rust-windows-sys-0.60.2
  (crate "windows-sys" "0.60.2" "1jrbc615ihqnhjhxplr2kw7rasrskv9wj3lr80hgfd42sbj01xgj"))
(define rust-windows-sys-0.61.2
  (crate "windows-sys" "0.61.2" "1z7k3y9b6b5h52kid57lvmvm05362zv1v8w0gc7xyv5xphlp44xf"))
(define rust-windows-targets-0.42.2
  (crate "windows-targets" "0.42.2" "0wfhnib2fisxlx8c507dbmh97kgij4r6kcxdi0f9nk6l1k080lcf"))
(define rust-windows-targets-0.48.5
  (crate "windows-targets" "0.48.5" "034ljxqshifs1lan89xwpcy1hp0lhdh4b5n0d2z4fwjx2piacbws"))
(define rust-windows-targets-0.52.6
  (crate "windows-targets" "0.52.6" "0wwrx625nwlfp7k93r2rra568gad1mwd888h1jwnl0vfg5r4ywlv"))
(define rust-windows-targets-0.53.5
  (crate "windows-targets" "0.53.5" "1wv9j2gv3l6wj3gkw5j1kr6ymb5q6dfc42yvydjhv3mqa7szjia9"))
(define rust-windows-threading-0.1.0
  (crate "windows-threading" "0.1.0" "19jpn37zpjj2q7pn07dpq0ay300w65qx7wdp13wbp8qf5snn6r5n"))
(define rust-windows-version-0.1.7
  (crate "windows-version" "0.1.7" "0c9nnqpcq770977k77mw1p66gpw45khwhqkjdcrd1f89l4fhl1p4"))
(define rust-windows_aarch64_gnullvm-0.42.2
  (crate "windows_aarch64_gnullvm" "0.42.2" "1y4q0qmvl0lvp7syxvfykafvmwal5hrjb4fmv04bqs0bawc52yjr"))
(define rust-windows_aarch64_gnullvm-0.48.5
  (crate "windows_aarch64_gnullvm" "0.48.5" "1n05v7qblg1ci3i567inc7xrkmywczxrs1z3lj3rkkxw18py6f1b"))
(define rust-windows_aarch64_gnullvm-0.52.6
  (crate "windows_aarch64_gnullvm" "0.52.6" "1lrcq38cr2arvmz19v32qaggvj8bh1640mdm9c2fr877h0hn591j"))
(define rust-windows_aarch64_gnullvm-0.53.1
  (crate "windows_aarch64_gnullvm" "0.53.1" "0lqvdm510mka9w26vmga7hbkmrw9glzc90l4gya5qbxlm1pl3n59"))
(define rust-windows_aarch64_msvc-0.42.2
  (crate "windows_aarch64_msvc" "0.42.2" "0hsdikjl5sa1fva5qskpwlxzpc5q9l909fpl1w6yy1hglrj8i3p0"))
(define rust-windows_aarch64_msvc-0.48.5
  (crate "windows_aarch64_msvc" "0.48.5" "1g5l4ry968p73g6bg6jgyvy9lb8fyhcs54067yzxpcpkf44k2dfw"))
(define rust-windows_aarch64_msvc-0.52.6
  (crate "windows_aarch64_msvc" "0.52.6" "0sfl0nysnz32yyfh773hpi49b1q700ah6y7sacmjbqjjn5xjmv09"))
(define rust-windows_aarch64_msvc-0.53.1
  (crate "windows_aarch64_msvc" "0.53.1" "01jh2adlwx043rji888b22whx4bm8alrk3khjpik5xn20kl85mxr"))
(define rust-windows_i686_gnu-0.42.2
  (crate "windows_i686_gnu" "0.42.2" "0kx866dfrby88lqs9v1vgmrkk1z6af9lhaghh5maj7d4imyr47f6"))
(define rust-windows_i686_gnu-0.48.5
  (crate "windows_i686_gnu" "0.48.5" "0gklnglwd9ilqx7ac3cn8hbhkraqisd0n83jxzf9837nvvkiand7"))
(define rust-windows_i686_gnu-0.52.6
  (crate "windows_i686_gnu" "0.52.6" "02zspglbykh1jh9pi7gn8g1f97jh1rrccni9ivmrfbl0mgamm6wf"))
(define rust-windows_i686_gnu-0.53.1
  (crate "windows_i686_gnu" "0.53.1" "18wkcm82ldyg4figcsidzwbg1pqd49jpm98crfz0j7nqd6h6s3ln"))
(define rust-windows_i686_gnullvm-0.52.6
  (crate "windows_i686_gnullvm" "0.52.6" "0rpdx1537mw6slcpqa0rm3qixmsb79nbhqy5fsm3q2q9ik9m5vhf"))
(define rust-windows_i686_gnullvm-0.53.1
  (crate "windows_i686_gnullvm" "0.53.1" "030qaxqc4salz6l4immfb6sykc6gmhyir9wzn2w8mxj8038mjwzs"))
(define rust-windows_i686_msvc-0.42.2
  (crate "windows_i686_msvc" "0.42.2" "0q0h9m2aq1pygc199pa5jgc952qhcnf0zn688454i7v4xjv41n24"))
(define rust-windows_i686_msvc-0.48.5
  (crate "windows_i686_msvc" "0.48.5" "01m4rik437dl9rdf0ndnm2syh10hizvq0dajdkv2fjqcywrw4mcg"))
(define rust-windows_i686_msvc-0.52.6
  (crate "windows_i686_msvc" "0.52.6" "0rkcqmp4zzmfvrrrx01260q3xkpzi6fzi2x2pgdcdry50ny4h294"))
(define rust-windows_i686_msvc-0.53.1
  (crate "windows_i686_msvc" "0.53.1" "1hi6scw3mn2pbdl30ji5i4y8vvspb9b66l98kkz350pig58wfyhy"))
(define rust-windows_x86_64_gnu-0.42.2
  (crate "windows_x86_64_gnu" "0.42.2" "0dnbf2xnp3xrvy8v9mgs3var4zq9v9yh9kv79035rdgyp2w15scd"))
(define rust-windows_x86_64_gnu-0.48.5
  (crate "windows_x86_64_gnu" "0.48.5" "13kiqqcvz2vnyxzydjh73hwgigsdr2z1xpzx313kxll34nyhmm2k"))
(define rust-windows_x86_64_gnu-0.52.6
  (crate "windows_x86_64_gnu" "0.52.6" "0y0sifqcb56a56mvn7xjgs8g43p33mfqkd8wj1yhrgxzma05qyhl"))
(define rust-windows_x86_64_gnu-0.53.1
  (crate "windows_x86_64_gnu" "0.53.1" "16d4yiysmfdlsrghndr97y57gh3kljkwhfdbcs05m1jasz6l4f4w"))
(define rust-windows_x86_64_gnullvm-0.42.2
  (crate "windows_x86_64_gnullvm" "0.42.2" "18wl9r8qbsl475j39zvawlidp1bsbinliwfymr43fibdld31pm16"))
(define rust-windows_x86_64_gnullvm-0.48.5
  (crate "windows_x86_64_gnullvm" "0.48.5" "1k24810wfbgz8k48c2yknqjmiigmql6kk3knmddkv8k8g1v54yqb"))
(define rust-windows_x86_64_gnullvm-0.52.6
  (crate "windows_x86_64_gnullvm" "0.52.6" "03gda7zjx1qh8k9nnlgb7m3w3s1xkysg55hkd1wjch8pqhyv5m94"))
(define rust-windows_x86_64_gnullvm-0.53.1
  (crate "windows_x86_64_gnullvm" "0.53.1" "1qbspgv4g3q0vygkg8rnql5c6z3caqv38japiynyivh75ng1gyhg"))
(define rust-windows_x86_64_msvc-0.42.2
  (crate "windows_x86_64_msvc" "0.42.2" "1w5r0q0yzx827d10dpjza2ww0j8iajqhmb54s735hhaj66imvv4s"))
(define rust-windows_x86_64_msvc-0.48.5
  (crate "windows_x86_64_msvc" "0.48.5" "0f4mdp895kkjh9zv8dxvn4pc10xr7839lf5pa9l0193i2pkgr57d"))
(define rust-windows_x86_64_msvc-0.52.6
  (crate "windows_x86_64_msvc" "0.52.6" "1v7rb5cibyzx8vak29pdrk8nx9hycsjs4w0jgms08qk49jl6v7sq"))
(define rust-windows_x86_64_msvc-0.53.1
  (crate "windows_x86_64_msvc" "0.53.1" "0l6npq76vlq4ksn4bwsncpr8508mk0gmznm6wnhjg95d19gzzfyn"))
(define rust-winnow-0.5.40
  (crate "winnow" "0.5.40" "0xk8maai7gyxda673mmw3pj1hdizy5fpi7287vaywykkk19sk4zm"))
(define rust-winnow-0.7.15
  (crate "winnow" "0.7.15" "0i9rkl2rqpbnnxlgs20gmkj3nd0b2k8q55mjmpc2ybb84xwxjyfz"))
(define rust-winnow-1.0.2
  (crate "winnow" "1.0.2" "1l7xnfvlgy4da6gq5ip2bgcm8i9d0rwzaxg1p88nlw8lxy5p1q9f"))
(define rust-winnow-1.0.3
  (crate "winnow" "1.0.3" "1wajycd3krn6h699vydjv7hm0ll5l31p899qzpk59y2is74y34h5"))
(define rust-winreg-0.55.0
  (crate "winreg" "0.55.0" "15xy060vylrsp91bc0ximx3xziwipzlrn1n2ab19w3n56x9pcnnb"))
(define rust-wit-bindgen-0.51.0
  (crate "wit-bindgen" "0.51.0" "19fazgch8sq5cvjv3ynhhfh5d5x08jq2pkw8jfb05vbcyqcr496p"))
(define rust-wit-bindgen-0.57.1
  (crate "wit-bindgen" "0.57.1" "0vjk2jb593ri9k1aq4iqs2si9mrw5q46wxnn78im7hm7hx799gqy"))
(define rust-wit-bindgen-core-0.51.0
  (crate "wit-bindgen-core" "0.51.0" "1p2jszqsqbx8k7y8nwvxg65wqzxjm048ba5phaq8r9iy9ildwqga"))
(define rust-wit-bindgen-rust-0.51.0
  (crate "wit-bindgen-rust" "0.51.0" "08bzn5fsvkb9x9wyvyx98qglknj2075xk1n7c5jxv15jykh6didp"))
(define rust-wit-bindgen-rust-macro-0.51.0
  (crate "wit-bindgen-rust-macro" "0.51.0" "0ymizapzv2id89igxsz2n587y2hlfypf6n8kyp68x976fzyrn3qc"))
(define rust-wit-component-0.244.0
  (crate "wit-component" "0.244.0" "1clwxgsgdns3zj2fqnrjcp8y5gazwfa1k0sy5cbk0fsmx4hflrlx"))
(define rust-wit-parser-0.244.0
  (crate "wit-parser" "0.244.0" "0dm7avvdxryxd5b02l0g5h6933z1cw5z0d4wynvq2cywq55srj7c"))
(define rust-writeable-0.6.3
  (crate "writeable" "0.6.3" "1i54d13h9bpap2hf13xcry1s4lxh7ap3923g8f3c0grd7c9fbyhz"))
(define rust-wry-0.54.4
  (crate "wry" "0.54.4" "1g7d2k1zhd2h970s3dkxpw0ja22szx6hs06y8ibmw8knhrfi7a75"))
(define rust-wry-0.55.1
  (crate "wry" "0.55.1" "054mw4y35lk2nirgpdrx25kq7rcx2h6q32sp2v0djpx5v9qrhvqq"))
(define rust-x11-2.21.0
  (crate "x11" "2.21.0" "0bnvl09d7044k067gqdx1ln2r0ljp5f4675icwb0216d9i3aabah"))
(define rust-x11-dl-2.21.0
  (crate "x11-dl" "2.21.0" "0vsiq62xpcfm0kn9zjw5c9iycvccxl22jya8wnk18lyxzqj5jwrq"))
(define rust-x11rb-0.13.2
  (crate "x11rb" "0.13.2" "053lvnaw9ycbl791mgwly2hw27q6vqgzrb1y5kz1as52wmdsm4wr"))
(define rust-x11rb-protocol-0.13.2
  (crate "x11rb-protocol" "0.13.2" "1g81cznbyn522b0fbis0i44wh3adad2vhsz5pzf99waf3sbc4vza"))
(define rust-xattr-1.6.1
  (crate "xattr" "1.6.1" "0ml1mb43gqasawillql6b344m0zgq8mz0isi11wj8vbg43a5mr1j"))
(define rust-xdg-home-1.3.0
  (crate "xdg-home" "1.3.0" "1xm122zz0wjc8p8cmchij0j9nw34hwncb39jc7dc0mgvb2rdl77c"))
(define rust-xkeysym-0.2.1
  (crate "xkeysym" "0.2.1" "0mksx670cszyd7jln6s7dhkw11hdfv7blwwr3isq98k22ljh1k5r"))
(define rust-yoke-0.8.2
  (crate "yoke" "0.8.2" "1jprcs7a98a5whvfs6r3jvfh1nnfp6zyijl7y4ywmn88lzywbs5b"))
(define rust-yoke-0.8.3
  (crate "yoke" "0.8.3" "1xgyj6c2lxj2bp891ynmhws87c6z7yyv2li1v0ss9di40hxf57vh"))
(define rust-yoke-derive-0.8.2
  (crate "yoke-derive" "0.8.2" "13l5y5sz4lqm7rmyakjbh6vwgikxiql51xfff9hq2j485hk4r16y"))
(define rust-zbus-4.4.0
  (crate "zbus" "4.4.0" "09f7916lp7haxv1y5zgcg99ny15whi6dn3waf1afcafxx8mh35xv"))
(define rust-zbus-5.18.0
  (crate "zbus" "5.18.0" "12p9swv45ja31c18a65vkd4a9rr1xbm7cyvi73kkjq39vihgn67y"))
(define rust-zbus_macros-4.4.0
  (crate "zbus_macros" "4.4.0" "0glqn6ddgv4ra734p343a41rrxb0phy1v13dljzhpsc1f10bjz96"))
(define rust-zbus_macros-5.18.0
  (crate "zbus_macros" "5.18.0" "068ix4mznsnwp3r63c5f0gnqxl0j9qvdyc0s5922ppwjxl5li5py"))
(define rust-zbus_names-3.0.0
  (crate "zbus_names" "3.0.0" "0v1f0ajwafj47bf11yp0xdgp26r93lslr9nb2v6624h2gppiz6sb"))
(define rust-zbus_names-4.3.4
  (crate "zbus_names" "4.3.4" "0kk250s3x1fxpz9fvhdr64ydbacpn8ah23hy021yhlzzlfs8igyq"))
(define rust-zerocopy-0.8.48
  (crate "zerocopy" "0.8.48" "1sb8plax8jbrsng1jdval7bdhk7hhrx40dz3hwh074k6knzkgm7f"))
(define rust-zerocopy-0.8.52
  (crate "zerocopy" "0.8.52" "0gv563swc1yn3k8w3wjj07a8q293rkx99nfp3a25vzzmbycj446f"))
(define rust-zerocopy-derive-0.8.48
  (crate "zerocopy-derive" "0.8.48" "1m5s0g92cxggqc74j83k1priz24k3z93sj5gadppd20p9c4cvqvh"))
(define rust-zerocopy-derive-0.8.52
  (crate "zerocopy-derive" "0.8.52" "0c3rhsh4sd9kdym4z55zprybjkydy9y2gvw75d72aapcfa5z7rqs"))
(define rust-zerofrom-0.1.7
  (crate "zerofrom" "0.1.7" "1py40in4rirc9q8w36q67pld0zk8ssg024xhh0cncxgal7ra3yk9"))
(define rust-zerofrom-0.1.8
  (crate "zerofrom" "0.1.8" "0wjjdj7gdmd0iq91gzkxl7dlv0nhkk80l4bmdpzh3a1yh48mmh0f"))
(define rust-zerofrom-derive-0.1.7
  (crate "zerofrom-derive" "0.1.7" "18c4wsnznhdxx6m80piil1lbyszdiwsshgjrybqcm4b6qic22lqi"))
(define rust-zeroize-1.8.2
  (crate "zeroize" "1.8.2" "1l48zxgcv34d7kjskr610zqsm6j2b4fcr2vfh9jm9j1jgvk58wdr"))
(define rust-zeroize-1.9.0
  (crate "zeroize" "1.9.0" "0kpnij2v1ig6g2mhc0bnci0lrdfdhiq40afbc0fahajqc9jiag71"))
(define rust-zeroize_derive-1.5.0
  (crate "zeroize_derive" "1.5.0" "0a7kq8srk81pn23xqn7c9jw1jpnfy41ffn802x1zrqqgpdf6al1w"))
(define rust-zerotrie-0.2.4
  (crate "zerotrie" "0.2.4" "1gr0pkcn3qsr6in6iixqyp0vbzwf2j1jzyvh7yl2yydh3p9m548g"))
(define rust-zerovec-0.11.6
  (crate "zerovec" "0.11.6" "0fdjsy6b31q9i0d73sl7xjd12xadbwi45lkpfgqnmasrqg5i3ych"))
(define rust-zerovec-derive-0.11.3
  (crate "zerovec-derive" "0.11.3" "0m85qj92mmfvhjra6ziqky5b1p4kcmp5069k7kfadp5hr8jw8pb2"))
(define rust-zip-8.6.0
  (crate "zip" "8.6.0" "16w0aiqiymyy6kjri0aykkmh45pbk6a6ck69hxhal0hm72ssc11d"))
(define rust-zip-9.0.4
  (crate "zip" "9.0.4" "08nwkmhl2ayrnw7vk8al3fxx88vbx0a2hwnjhfgz8kd58x5i2m59"))
(define rust-zlib-rs-0.6.3
  (crate "zlib-rs" "0.6.3" "04qmv85amq6sv73bzqgvnlsk9mnrl97rygzf2v4zjcx1807d9qrv"))
(define rust-zlib-rs-0.6.8
  (crate "zlib-rs" "0.6.8" "04j158293bx73kv5pj1i89ai411q7fxc9zwk3wkpqgb9gj7fas5j"))
(define rust-zmij-1.0.21
  (crate "zmij" "1.0.21" "1amb5i6gz7yjb0dnmz5y669674pqmwbj44p4yfxfv2ncgvk8x15q"))
(define rust-zopfli-0.8.3
  (crate "zopfli" "0.8.3" "0jaj5dyh3mks0805h4ldrsh5pwq4i2jc9dc9zwjm91k3gmwxhp7h"))
(define rust-zstd-0.13.3
  (crate "zstd" "0.13.3" "12n0h4w9l526li7jl972rxpyf012jw3nwmji2qbjghv9ll8y67p9"))
(define rust-zstd-0.14.3
  (crate "zstd" "0.14.3" "0w1wzfxmypnq1f1p7s0g8abn7ba6zkp7wxpggccl0vmgj2zyjfnv"))
(define rust-zstd-safe-7.2.4
  (crate "zstd-safe" "7.2.4" "179vxmkzhpz6cq6mfzvgwc99bpgllkr6lwxq7ylh5dmby3aw8jcg"))
(define rust-zstd-safe-8.2.0
  (crate "zstd-safe" "8.2.0" "0js3swa592j55g2b76vd6719h0qa5cdj48n7f6vskq99dgqj1mfy"))
(define rust-zstd-sys-2.0.16-zstd.1.5.7
  (crate "zstd-sys" "2.0.16+zstd.1.5.7" "0j1pd2iaqpvaxlgqmmijj68wma7xwdv9grrr63j873yw5ay9xqci"))
(define rust-zstd-sys-2.1.2-zstd.1.5.7
  (crate "zstd-sys" "2.1.2+zstd.1.5.7" "1lsfr0hj9cp42lnfsnfriqcg1yvpj4jbbnxvnz5j68rvajfdl6j8"))
(define rust-zvariant-4.2.0
  (crate "zvariant" "4.2.0" "1zl1ika7zd9bxkd0bqc78h9bykvk6xc98965iz1p3i51p452k110"))
(define rust-zvariant-5.13.1
  (crate "zvariant" "5.13.1" "04a9r40d5vd4q6gaww8bynjrnk7mmam4bzvg8mm7h1x9saya1qmy"))
(define rust-zvariant_derive-4.2.0
  (crate "zvariant_derive" "4.2.0" "0jf408h0s83krxwm7wl62fnssin1kcklmb1bcn83ls6sddabmqkk"))
(define rust-zvariant_derive-5.13.1
  (crate "zvariant_derive" "5.13.1" "04iywbj0dg5v6iapb6vqiwz3mj67753kzzhbfyb0fy0qd8hhi9rq"))
(define rust-zvariant_utils-2.1.0
  (crate "zvariant_utils" "2.1.0" "0h43h3jcw8rmjr390rdqnhkb9nn3913pgkvb75am1frxrkvwy6y5"))
(define rust-zvariant_utils-3.5.0
  (crate "zvariant_utils" "3.5.0" "1iy79yppaqsw0pjb8q7b36vivw7qsc1b4n0jg9090lmlz61r7jwh"))

(define scrcpy-gui-cargo-inputs
  (list rust-adler2-2.0.1
        rust-aes-0.9.0
        rust-aho-corasick-1.1.4
        rust-alloc-no-stdlib-2.0.4
        rust-alloc-stdlib-0.2.2
        rust-android_system_properties-0.1.5
        rust-anyhow-1.0.102
        rust-atk-0.18.2
        rust-atk-sys-0.18.2
        rust-atomic-waker-1.1.2
        rust-autocfg-1.5.0
        rust-base64-0.21.7
        rust-base64-0.22.1
        rust-bit-set-0.8.0
        rust-bit-vec-0.8.0
        rust-bitflags-1.3.2
        rust-bitflags-2.11.1
        rust-block-buffer-0.10.4
        rust-block-buffer-0.12.0
        rust-block2-0.6.2
        rust-brotli-8.0.2
        rust-brotli-decompressor-5.0.0
        rust-bumpalo-3.20.2
        rust-bytemuck-1.25.0
        rust-byteorder-1.5.0
        rust-bytes-1.11.1
        rust-bzip2-0.6.1
        rust-cairo-rs-0.18.5
        rust-cairo-sys-rs-0.18.2
        rust-camino-1.2.2
        rust-cargo-platform-0.1.9
        rust-cargo_metadata-0.19.2
        rust-cargo_toml-0.22.3
        rust-cc-1.2.61
        rust-cesu8-1.1.0
        rust-cfb-0.7.3
        rust-cfg-expr-0.15.8
        rust-cfg-if-1.0.4
        rust-chrono-0.4.44
        rust-cipher-0.5.1
        rust-cmov-0.5.3
        rust-combine-4.6.7
        rust-const-oid-0.10.2
        rust-constant_time_eq-0.4.2
        rust-convert_case-0.4.0
        rust-cookie-0.18.1
        rust-core-foundation-0.10.1
        rust-core-foundation-sys-0.8.7
        rust-core-graphics-0.25.0
        rust-core-graphics-types-0.2.0
        rust-cpubits-0.1.1
        rust-cpufeatures-0.2.17
        rust-cpufeatures-0.3.0
        rust-crc32fast-1.5.0
        rust-crossbeam-channel-0.5.15
        rust-crossbeam-utils-0.8.21
        rust-crypto-common-0.1.7
        rust-crypto-common-0.2.1
        rust-cssparser-0.29.6
        rust-cssparser-0.36.0
        rust-cssparser-macros-0.6.1
        rust-ctor-0.2.9
        rust-ctutils-0.4.2
        rust-darling-0.23.0
        rust-darling_core-0.23.0
        rust-darling_macro-0.23.0
        rust-deflate64-0.1.12
        rust-deranged-0.5.8
        rust-derive_more-0.99.20
        rust-derive_more-2.1.1
        rust-derive_more-impl-2.1.1
        rust-digest-0.10.7
        rust-digest-0.11.2
        rust-dirs-6.0.0
        rust-dirs-sys-0.5.0
        rust-dispatch2-0.3.1
        rust-displaydoc-0.2.5
        rust-dlopen2-0.8.2
        rust-dlopen2_derive-0.4.3
        rust-dom_query-0.27.0
        rust-dpi-0.1.2
        rust-dtoa-1.0.11
        rust-dtoa-short-0.3.5
        rust-dunce-1.0.5
        rust-dyn-clone-1.0.20
        rust-embed-resource-3.0.9
        rust-embed_plist-1.2.2
        rust-encoding_rs-0.8.35
        rust-equivalent-1.0.2
        rust-erased-serde-0.4.10
        rust-errno-0.3.14
        rust-fastrand-2.4.1
        rust-fdeflate-0.3.7
        rust-field-offset-0.3.6
        rust-filetime-0.2.27
        rust-find-msvc-tools-0.1.9
        rust-flate2-1.1.9
        rust-fnv-1.0.7
        rust-foldhash-0.1.5
        rust-foldhash-0.2.0
        rust-foreign-types-0.3.2
        rust-foreign-types-0.5.0
        rust-foreign-types-macros-0.2.3
        rust-foreign-types-shared-0.1.1
        rust-foreign-types-shared-0.3.1
        rust-form_urlencoded-1.2.2
        rust-futf-0.1.5
        rust-futures-channel-0.3.32
        rust-futures-core-0.3.32
        rust-futures-executor-0.3.32
        rust-futures-io-0.3.32
        rust-futures-macro-0.3.32
        rust-futures-sink-0.3.32
        rust-futures-task-0.3.32
        rust-futures-util-0.3.32
        rust-fxhash-0.2.1
        rust-gdk-0.18.2
        rust-gdk-pixbuf-0.18.5
        rust-gdk-pixbuf-sys-0.18.0
        rust-gdk-sys-0.18.2
        rust-gdkwayland-sys-0.18.2
        rust-gdkx11-0.18.2
        rust-gdkx11-sys-0.18.2
        rust-generic-array-0.14.7
        rust-gethostname-1.1.0
        rust-getrandom-0.1.16
        rust-getrandom-0.2.17
        rust-getrandom-0.3.4
        rust-getrandom-0.4.2
        rust-gio-0.18.4
        rust-gio-sys-0.18.1
        rust-glib-0.18.5
        rust-glib-macros-0.18.5
        rust-glib-sys-0.18.1
        rust-glob-0.3.3
        rust-global-hotkey-0.8.0
        rust-gobject-sys-0.18.0
        rust-gtk-0.18.2
        rust-gtk-sys-0.18.2
        rust-gtk3-macros-0.18.2
        rust-hashbrown-0.12.3
        rust-hashbrown-0.15.5
        rust-hashbrown-0.17.0
        rust-heck-0.4.1
        rust-heck-0.5.0
        rust-hex-0.4.3
        rust-hmac-0.13.0
        rust-html5ever-0.29.1
        rust-html5ever-0.38.0
        rust-http-1.4.0
        rust-http-body-1.0.1
        rust-http-body-util-0.1.3
        rust-httparse-1.10.1
        rust-hybrid-array-0.4.11
        rust-hyper-1.9.0
        rust-hyper-tls-0.6.0
        rust-hyper-util-0.1.20
        rust-iana-time-zone-0.1.65
        rust-iana-time-zone-haiku-0.1.2
        rust-ico-0.5.0
        rust-icu_collections-2.2.0
        rust-icu_locale_core-2.2.0
        rust-icu_normalizer-2.2.0
        rust-icu_normalizer_data-2.2.0
        rust-icu_properties-2.2.0
        rust-icu_properties_data-2.2.0
        rust-icu_provider-2.2.0
        rust-id-arena-2.3.0
        rust-ident_case-1.0.1
        rust-idna-1.1.0
        rust-idna_adapter-1.2.2
        rust-indexmap-1.9.3
        rust-indexmap-2.14.0
        rust-infer-0.19.0
        rust-inout-0.2.2
        rust-ipnet-2.12.0
        rust-iri-string-0.7.12
        rust-is-docker-0.2.0
        rust-is-wsl-0.4.0
        rust-itoa-1.0.18
        rust-javascriptcore-rs-1.1.2
        rust-javascriptcore-rs-sys-1.1.1
        rust-jni-0.21.1
        rust-jni-sys-0.3.1
        rust-jni-sys-0.4.1
        rust-jni-sys-macros-0.4.1
        rust-jobserver-0.1.34
        rust-js-sys-0.3.97
        rust-json-patch-3.0.1
        rust-jsonptr-0.6.3
        rust-keyboard-types-0.7.0
        rust-kuchikiki-0.8.8-speedreader
        rust-leb128fmt-0.1.0
        rust-libappindicator-0.9.0
        rust-libappindicator-sys-0.9.0
        rust-libbz2-rs-sys-0.2.3
        rust-libc-0.2.186
        rust-libloading-0.7.4
        rust-libredox-0.1.16
        rust-linux-raw-sys-0.12.1
        rust-litemap-0.8.2
        rust-lock_api-0.4.14
        rust-log-0.4.29
        rust-lzma-rust2-0.16.2
        rust-mac-0.1.1
        rust-markup5ever-0.14.1
        rust-markup5ever-0.38.0
        rust-match_token-0.1.0
        rust-matches-0.1.10
        rust-memchr-2.8.0
        rust-memoffset-0.9.1
        rust-mime-0.3.17
        rust-miniz_oxide-0.8.9
        rust-mio-1.2.0
        rust-muda-0.17.2
        rust-native-tls-0.2.18
        rust-ndk-0.9.0
        rust-ndk-context-0.1.1
        rust-ndk-sys-0.6.0-11769913
        rust-new_debug_unreachable-1.0.6
        rust-nodrop-0.1.14
        rust-num-conv-0.2.1
        rust-num-traits-0.2.19
        rust-num_enum-0.7.6
        rust-num_enum_derive-0.7.6
        rust-objc2-0.6.4
        rust-objc2-app-kit-0.3.2
        rust-objc2-core-foundation-0.3.2
        rust-objc2-core-graphics-0.3.2
        rust-objc2-encode-4.1.0
        rust-objc2-exception-helper-0.1.1
        rust-objc2-foundation-0.3.2
        rust-objc2-io-surface-0.3.2
        rust-objc2-quartz-core-0.3.2
        rust-objc2-ui-kit-0.3.2
        rust-objc2-web-kit-0.3.2
        rust-once_cell-1.21.4
        rust-open-5.3.4
        rust-openssl-0.10.78
        rust-openssl-macros-0.1.1
        rust-openssl-probe-0.2.1
        rust-openssl-sys-0.9.114
        rust-option-ext-0.2.0
        rust-os_pipe-1.2.3
        rust-pango-0.18.3
        rust-pango-sys-0.18.0
        rust-parking_lot-0.12.5
        rust-parking_lot_core-0.9.12
        rust-pathdiff-0.2.3
        rust-pbkdf2-0.13.0
        rust-percent-encoding-2.3.2
        rust-phf-0.8.0
        rust-phf-0.10.1
        rust-phf-0.11.3
        rust-phf-0.13.1
        rust-phf_codegen-0.8.0
        rust-phf_codegen-0.11.3
        rust-phf_codegen-0.13.1
        rust-phf_generator-0.8.0
        rust-phf_generator-0.10.0
        rust-phf_generator-0.11.3
        rust-phf_generator-0.13.1
        rust-phf_macros-0.10.0
        rust-phf_macros-0.11.3
        rust-phf_macros-0.13.1
        rust-phf_shared-0.8.0
        rust-phf_shared-0.10.0
        rust-phf_shared-0.11.3
        rust-phf_shared-0.13.1
        rust-pin-project-lite-0.2.17
        rust-pkg-config-0.3.33
        rust-plain-0.2.3
        rust-plist-1.9.0
        rust-png-0.17.16
        rust-potential_utf-0.1.5
        rust-powerfmt-0.2.0
        rust-ppmd-rust-1.4.0
        rust-ppv-lite86-0.2.21
        rust-precomputed-hash-0.1.1
        rust-prettyplease-0.2.37
        rust-proc-macro-crate-1.3.1
        rust-proc-macro-crate-2.0.2
        rust-proc-macro-crate-3.5.0
        rust-proc-macro-error-1.0.4
        rust-proc-macro-error-attr-1.0.4
        rust-proc-macro-hack-0.5.20-deprecated
        rust-proc-macro2-1.0.106
        rust-quick-xml-0.39.2
        rust-quote-1.0.45
        rust-r-efi-5.3.0
        rust-r-efi-6.0.0
        rust-rand-0.7.3
        rust-rand-0.8.6
        rust-rand_chacha-0.2.2
        rust-rand_chacha-0.3.1
        rust-rand_core-0.5.1
        rust-rand_core-0.6.4
        rust-rand_hc-0.2.0
        rust-rand_pcg-0.2.1
        rust-raw-window-handle-0.6.2
        rust-redox_syscall-0.5.18
        rust-redox_syscall-0.7.4
        rust-redox_users-0.5.2
        rust-ref-cast-1.0.25
        rust-ref-cast-impl-1.0.25
        rust-regex-1.12.3
        rust-regex-automata-0.4.14
        rust-regex-syntax-0.8.10
        rust-reqwest-0.13.3
        rust-rfd-0.16.0
        rust-rustc-hash-2.1.2
        rust-rustc_version-0.4.1
        rust-rustix-1.1.4
        rust-rustls-pki-types-1.14.1
        rust-rustversion-1.0.22
        rust-same-file-1.0.6
        rust-schannel-0.1.29
        rust-schemars-0.8.22
        rust-schemars-0.9.0
        rust-schemars-1.2.1
        rust-schemars_derive-0.8.22
        rust-scopeguard-1.2.0
        rust-security-framework-3.7.0
        rust-security-framework-sys-2.17.0
        rust-selectors-0.24.0
        rust-selectors-0.36.1
        rust-semver-1.0.28
        rust-serde-1.0.228
        rust-serde-untagged-0.1.9
        rust-serde_core-1.0.228
        rust-serde_derive-1.0.228
        rust-serde_derive_internals-0.29.1
        rust-serde_json-1.0.149
        rust-serde_repr-0.1.20
        rust-serde_spanned-0.6.9
        rust-serde_spanned-1.1.1
        rust-serde_with-3.18.0
        rust-serde_with_macros-3.18.0
        rust-serialize-to-javascript-0.1.2
        rust-serialize-to-javascript-impl-0.1.2
        rust-servo_arc-0.2.0
        rust-servo_arc-0.4.3
        rust-sha1-0.11.0
        rust-sha2-0.10.9
        rust-shared_child-1.1.1
        rust-shlex-1.3.0
        rust-sigchld-0.2.4
        rust-signal-hook-0.3.18
        rust-signal-hook-registry-1.4.8
        rust-simd-adler32-0.3.9
        rust-siphasher-0.3.11
        rust-siphasher-1.0.2
        rust-slab-0.4.12
        rust-smallvec-1.15.1
        rust-socket2-0.6.3
        rust-softbuffer-0.4.8
        rust-soup3-0.5.0
        rust-soup3-sys-0.5.0
        rust-stable_deref_trait-1.2.1
        rust-string_cache-0.8.9
        rust-string_cache-0.9.0
        rust-string_cache_codegen-0.5.4
        rust-string_cache_codegen-0.6.1
        rust-strsim-0.11.1
        rust-swift-rs-1.0.7
        rust-syn-1.0.109
        rust-syn-2.0.117
        rust-sync_wrapper-1.0.2
        rust-synstructure-0.13.2
        rust-system-deps-6.2.2
        rust-tao-0.34.8
        rust-tao-macros-0.1.3
        rust-tar-0.4.45
        rust-target-lexicon-0.12.16
        rust-tauri-2.10.3
        rust-tauri-build-2.5.6
        rust-tauri-codegen-2.5.5
        rust-tauri-macros-2.5.5
        rust-tauri-plugin-2.5.4
        rust-tauri-plugin-dialog-2.7.0
        rust-tauri-plugin-fs-2.5.0
        rust-tauri-plugin-global-shortcut-2.3.2
        rust-tauri-plugin-shell-2.3.5
        rust-tauri-runtime-2.10.1
        rust-tauri-runtime-wry-2.10.1
        rust-tauri-utils-2.8.3
        rust-tauri-winres-0.3.6
        rust-tempfile-3.27.0
        rust-tendril-0.4.3
        rust-tendril-0.5.0
        rust-thiserror-1.0.69
        rust-thiserror-2.0.18
        rust-thiserror-impl-1.0.69
        rust-thiserror-impl-2.0.18
        rust-time-0.3.47
        rust-time-core-0.1.8
        rust-time-macros-0.2.27
        rust-tinystr-0.8.3
        rust-tokio-1.52.1
        rust-tokio-macros-2.7.0
        rust-tokio-native-tls-0.3.1
        rust-tokio-util-0.7.18
        rust-toml-0.8.2
        rust-toml-0.9.12-spec-1.1.0
        rust-toml-1.1.2-spec-1.1.0
        rust-toml_datetime-0.6.3
        rust-toml_datetime-0.7.5-spec-1.1.0
        rust-toml_datetime-1.1.1-spec-1.1.0
        rust-toml_edit-0.19.15
        rust-toml_edit-0.20.2
        rust-toml_edit-0.25.11-spec-1.1.0
        rust-toml_parser-1.1.2-spec-1.1.0
        rust-toml_writer-1.1.1-spec-1.1.0
        rust-tower-0.5.3
        rust-tower-http-0.6.8
        rust-tower-layer-0.3.3
        rust-tower-service-0.3.3
        rust-tracing-0.1.44
        rust-tracing-core-0.1.36
        rust-tray-icon-0.21.3
        rust-try-lock-0.2.5
        rust-typed-path-0.12.3
        rust-typeid-1.0.3
        rust-typenum-1.20.0
        rust-unic-char-property-0.9.0
        rust-unic-char-range-0.9.0
        rust-unic-common-0.9.0
        rust-unic-ucd-ident-0.9.0
        rust-unic-ucd-version-0.9.0
        rust-unicode-ident-1.0.24
        rust-unicode-segmentation-1.13.2
        rust-unicode-xid-0.2.6
        rust-url-2.5.8
        rust-urlpattern-0.3.0
        rust-utf-8-0.7.6
        rust-utf8_iter-1.0.4
        rust-uuid-1.23.1
        rust-vcpkg-0.2.15
        rust-version-compare-0.2.1
        rust-version_check-0.9.5
        rust-vswhom-0.1.0
        rust-vswhom-sys-0.1.3
        rust-walkdir-2.5.0
        rust-want-0.3.1
        rust-wasi-0.9.0-wasi-snapshot-preview1
        rust-wasi-0.11.1-wasi-snapshot-preview1
        rust-wasip2-1.0.3-wasi-0.2.9
        rust-wasip3-0.4.0-wasi-0.3.0-rc-2026-01-06
        rust-wasm-bindgen-0.2.120
        rust-wasm-bindgen-futures-0.4.70
        rust-wasm-bindgen-macro-0.2.120
        rust-wasm-bindgen-macro-support-0.2.120
        rust-wasm-bindgen-shared-0.2.120
        rust-wasm-encoder-0.244.0
        rust-wasm-metadata-0.244.0
        rust-wasm-streams-0.5.0
        rust-wasmparser-0.244.0
        rust-web-sys-0.3.97
        rust-web_atoms-0.2.4
        rust-webkit2gtk-2.0.2
        rust-webkit2gtk-sys-2.0.2
        rust-webview2-com-0.38.2
        rust-webview2-com-macros-0.8.1
        rust-webview2-com-sys-0.38.2
        rust-winapi-0.3.9
        rust-winapi-i686-pc-windows-gnu-0.4.0
        rust-winapi-util-0.1.11
        rust-winapi-x86_64-pc-windows-gnu-0.4.0
        rust-window-vibrancy-0.6.0
        rust-windows-0.61.3
        rust-windows-collections-0.2.0
        rust-windows-core-0.61.2
        rust-windows-core-0.62.2
        rust-windows-future-0.2.1
        rust-windows-implement-0.60.2
        rust-windows-interface-0.59.3
        rust-windows-link-0.1.3
        rust-windows-link-0.2.1
        rust-windows-numerics-0.2.0
        rust-windows-result-0.3.4
        rust-windows-result-0.4.1
        rust-windows-strings-0.4.2
        rust-windows-strings-0.5.1
        rust-windows-sys-0.45.0
        rust-windows-sys-0.59.0
        rust-windows-sys-0.60.2
        rust-windows-sys-0.61.2
        rust-windows-targets-0.42.2
        rust-windows-targets-0.52.6
        rust-windows-targets-0.53.5
        rust-windows-threading-0.1.0
        rust-windows-version-0.1.7
        rust-windows_aarch64_gnullvm-0.42.2
        rust-windows_aarch64_gnullvm-0.52.6
        rust-windows_aarch64_gnullvm-0.53.1
        rust-windows_aarch64_msvc-0.42.2
        rust-windows_aarch64_msvc-0.52.6
        rust-windows_aarch64_msvc-0.53.1
        rust-windows_i686_gnu-0.42.2
        rust-windows_i686_gnu-0.52.6
        rust-windows_i686_gnu-0.53.1
        rust-windows_i686_gnullvm-0.52.6
        rust-windows_i686_gnullvm-0.53.1
        rust-windows_i686_msvc-0.42.2
        rust-windows_i686_msvc-0.52.6
        rust-windows_i686_msvc-0.53.1
        rust-windows_x86_64_gnu-0.42.2
        rust-windows_x86_64_gnu-0.52.6
        rust-windows_x86_64_gnu-0.53.1
        rust-windows_x86_64_gnullvm-0.42.2
        rust-windows_x86_64_gnullvm-0.52.6
        rust-windows_x86_64_gnullvm-0.53.1
        rust-windows_x86_64_msvc-0.42.2
        rust-windows_x86_64_msvc-0.52.6
        rust-windows_x86_64_msvc-0.53.1
        rust-winnow-0.5.40
        rust-winnow-0.7.15
        rust-winnow-1.0.2
        rust-winreg-0.55.0
        rust-wit-bindgen-0.51.0
        rust-wit-bindgen-0.57.1
        rust-wit-bindgen-core-0.51.0
        rust-wit-bindgen-rust-0.51.0
        rust-wit-bindgen-rust-macro-0.51.0
        rust-wit-component-0.244.0
        rust-wit-parser-0.244.0
        rust-writeable-0.6.3
        rust-wry-0.54.4
        rust-x11-2.21.0
        rust-x11-dl-2.21.0
        rust-x11rb-0.13.2
        rust-x11rb-protocol-0.13.2
        rust-xattr-1.6.1
        rust-xkeysym-0.2.1
        rust-yoke-0.8.2
        rust-yoke-derive-0.8.2
        rust-zerocopy-0.8.48
        rust-zerocopy-derive-0.8.48
        rust-zerofrom-0.1.7
        rust-zerofrom-derive-0.1.7
        rust-zeroize-1.8.2
        rust-zerotrie-0.2.4
        rust-zerovec-0.11.6
        rust-zerovec-derive-0.11.3
        rust-zip-8.6.0
        rust-zlib-rs-0.6.3
        rust-zmij-1.0.21
        rust-zopfli-0.8.3
        rust-zstd-0.13.3
        rust-zstd-safe-7.2.4
        rust-zstd-sys-2.0.16-zstd.1.5.7))

(define faforever-client-cargo-inputs
  (list rust-Inflector-0.11.4
        rust-adler2-2.0.1
        rust-aes-0.8.4
        rust-aes-0.9.3
        rust-aho-corasick-1.1.4
        rust-alloc-no-stdlib-2.0.4
        rust-alloc-stdlib-0.2.4
        rust-android_system_properties-0.1.5
        rust-anyhow-1.0.104
        rust-async-broadcast-0.7.2
        rust-async-channel-2.5.0
        rust-async-executor-1.14.0
        rust-async-io-2.6.0
        rust-async-lock-3.4.2
        rust-async-process-2.5.0
        rust-async-recursion-1.1.1
        rust-async-signal-0.2.14
        rust-async-task-4.7.1
        rust-async-trait-0.1.92
        rust-atk-0.18.2
        rust-atk-sys-0.18.2
        rust-atomic-waker-1.1.2
        rust-autocfg-1.5.1
        rust-base64-0.21.7
        rust-base64-0.22.1
        rust-bit-set-0.8.0
        rust-bit-vec-0.8.0
        rust-bitflags-1.3.2
        rust-bitflags-2.13.0
        rust-block-buffer-0.10.4
        rust-block-buffer-0.12.1
        rust-block-padding-0.3.3
        rust-block2-0.6.2
        rust-blocking-1.6.2
        rust-brotli-8.0.4
        rust-brotli-decompressor-5.0.3
        rust-bs58-0.5.1
        rust-bumpalo-3.20.3
        rust-bytemuck-1.25.0
        rust-byteorder-1.5.0
        rust-bytes-1.11.1
        rust-bzip2-0.6.1
        rust-cairo-rs-0.18.5
        rust-cairo-sys-rs-0.18.2
        rust-camino-1.2.2
        rust-cargo-platform-0.1.9
        rust-cargo_metadata-0.19.2
        rust-cargo_toml-0.22.3
        rust-cbc-0.1.2
        rust-cc-1.2.64
        rust-cesu8-1.1.0
        rust-cfb-0.7.3
        rust-cfg-expr-0.15.8
        rust-cfg-if-1.0.4
        rust-cfg_aliases-0.2.1
        rust-chrono-0.4.45
        rust-cipher-0.4.4
        rust-cipher-0.5.2
        rust-cmov-0.5.4
        rust-combine-4.6.7
        rust-concurrent-queue-2.5.0
        rust-const-oid-0.10.2
        rust-constant_time_eq-0.6.1
        rust-cookie-0.18.1
        rust-core-foundation-0.9.4
        rust-core-foundation-0.10.1
        rust-core-foundation-sys-0.8.7
        rust-core-graphics-0.25.0
        rust-core-graphics-types-0.2.0
        rust-cpubits-0.1.1
        rust-cpufeatures-0.2.17
        rust-cpufeatures-0.3.1
        rust-crc32fast-1.5.0
        rust-crossbeam-channel-0.5.15
        rust-crossbeam-utils-0.8.21
        rust-crypto-common-0.1.7
        rust-crypto-common-0.2.2
        rust-cssparser-0.36.0
        rust-cssparser-macros-0.6.1
        rust-ctor-0.8.0
        rust-ctor-proc-macro-0.0.7
        rust-ctutils-0.4.5
        rust-darling-0.23.0
        rust-darling_core-0.23.0
        rust-darling_macro-0.23.0
        rust-data-encoding-2.11.0
        rust-dbus-0.9.11
        rust-dbus-secret-service-4.1.0
        rust-deflate64-0.1.12
        rust-deranged-0.5.8
        rust-derive_more-2.1.1
        rust-derive_more-impl-2.1.1
        rust-digest-0.10.7
        rust-digest-0.11.3
        rust-directories-5.0.1
        rust-dirs-6.0.0
        rust-dirs-sys-0.4.1
        rust-dirs-sys-0.5.0
        rust-dispatch2-0.3.1
        rust-displaydoc-0.2.6
        rust-dlopen2-0.8.2
        rust-dlopen2_derive-0.4.3
        rust-dom_query-0.27.0
        rust-dpi-0.1.2
        rust-dtoa-1.0.11
        rust-dtoa-short-0.3.5
        rust-dtor-0.3.0
        rust-dtor-proc-macro-0.0.6
        rust-dunce-1.0.5
        rust-dyn-clone-1.0.20
        rust-embed-resource-3.0.9
        rust-embed_plist-1.2.2
        rust-encoding_rs-0.8.35
        rust-endi-1.1.1
        rust-enumflags2-0.7.12
        rust-enumflags2_derive-0.7.12
        rust-equivalent-1.0.2
        rust-erased-serde-0.4.10
        rust-errno-0.3.14
        rust-event-listener-5.4.2
        rust-event-listener-strategy-0.5.4
        rust-fastrand-2.4.1
        rust-fdeflate-0.3.7
        rust-field-offset-0.3.6
        rust-find-msvc-tools-0.1.9
        rust-flate2-1.1.9
        rust-fnv-1.0.7
        rust-foldhash-0.1.5
        rust-foldhash-0.2.0
        rust-foreign-types-0.3.2
        rust-foreign-types-0.5.0
        rust-foreign-types-macros-0.2.3
        rust-foreign-types-shared-0.1.1
        rust-foreign-types-shared-0.3.1
        rust-form_urlencoded-1.2.2
        rust-futures-channel-0.3.32
        rust-futures-core-0.3.32
        rust-futures-executor-0.3.32
        rust-futures-io-0.3.32
        rust-futures-lite-2.6.1
        rust-futures-macro-0.3.32
        rust-futures-sink-0.3.32
        rust-futures-task-0.3.32
        rust-futures-util-0.3.32
        rust-gdk-0.18.2
        rust-gdk-pixbuf-0.18.5
        rust-gdk-pixbuf-sys-0.18.0
        rust-gdk-sys-0.18.2
        rust-gdkwayland-sys-0.18.2
        rust-gdkx11-0.18.2
        rust-gdkx11-sys-0.18.2
        rust-generic-array-0.14.7
        rust-getrandom-0.2.17
        rust-getrandom-0.3.4
        rust-getrandom-0.4.2
        rust-gio-0.18.4
        rust-gio-sys-0.18.1
        rust-glib-0.18.5
        rust-glib-macros-0.18.5
        rust-glib-sys-0.18.1
        rust-glob-0.3.3
        rust-gobject-sys-0.18.0
        rust-gtk-0.18.2
        rust-gtk-sys-0.18.2
        rust-gtk3-macros-0.18.2
        rust-h2-0.4.19
        rust-hashbrown-0.12.3
        rust-hashbrown-0.15.5
        rust-hashbrown-0.17.1
        rust-heck-0.4.1
        rust-heck-0.5.0
        rust-hermit-abi-0.5.2
        rust-hex-0.4.3
        rust-hkdf-0.12.4
        rust-hmac-0.12.1
        rust-hmac-0.13.0
        rust-html5ever-0.38.0
        rust-http-1.4.2
        rust-http-body-1.0.1
        rust-http-body-util-0.1.3
        rust-httparse-1.10.1
        rust-hybrid-array-0.4.15
        rust-hyper-1.10.1
        rust-hyper-rustls-0.27.9
        rust-hyper-tls-0.6.0
        rust-hyper-util-0.1.20
        rust-iana-time-zone-0.1.65
        rust-iana-time-zone-haiku-0.1.2
        rust-ico-0.5.0
        rust-icu_collections-2.2.0
        rust-icu_locale_core-2.2.0
        rust-icu_normalizer-2.2.0
        rust-icu_normalizer_data-2.2.0
        rust-icu_properties-2.2.0
        rust-icu_properties_data-2.2.0
        rust-icu_provider-2.2.0
        rust-id-arena-2.3.0
        rust-ident_case-1.0.1
        rust-idna-1.1.0
        rust-idna_adapter-1.2.2
        rust-indexmap-1.9.3
        rust-indexmap-2.14.0
        rust-infer-0.19.0
        rust-inout-0.1.4
        rust-inout-0.2.4
        rust-ipnet-2.12.0
        rust-is-docker-0.2.0
        rust-is-wsl-0.4.0
        rust-itoa-1.0.18
        rust-javascriptcore-rs-1.1.2
        rust-javascriptcore-rs-sys-1.1.1
        rust-jni-0.21.1
        rust-jni-sys-0.3.1
        rust-jni-sys-0.4.1
        rust-jni-sys-macros-0.4.1
        rust-jobserver-0.1.34
        rust-js-sys-0.3.102
        rust-json-patch-3.0.1
        rust-jsonptr-0.6.3
        rust-keyboard-types-0.7.0
        rust-keyring-3.6.3
        rust-lazy_static-1.5.0
        rust-leb128fmt-0.1.0
        rust-libappindicator-0.9.0
        rust-libappindicator-sys-0.9.0
        rust-libbz2-rs-sys-0.2.5
        rust-libc-0.2.186
        rust-libdbus-sys-0.2.7
        rust-libloading-0.7.4
        rust-libredox-0.1.17
        rust-linux-raw-sys-0.12.1
        rust-litemap-0.8.2
        rust-lock_api-0.4.14
        rust-log-0.4.32
        rust-lzma-rust2-0.22.0
        rust-mac-notification-sys-0.6.15
        rust-markup5ever-0.38.0
        rust-matchers-0.2.0
        rust-md5-0.7.0
        rust-memchr-2.8.2
        rust-memoffset-0.9.1
        rust-mime-0.3.17
        rust-mime_guess-2.0.5
        rust-miniz_oxide-0.8.9
        rust-mio-1.2.1
        rust-muda-0.19.2
        rust-native-tls-0.2.18
        rust-ndk-0.9.0
        rust-ndk-sys-0.6.0-11769913
        rust-new_debug_unreachable-1.0.6
        rust-nix-0.29.0
        rust-nix-0.31.3
        rust-notify-rust-4.18.0
        rust-nu-ansi-term-0.50.3
        rust-num-0.4.3
        rust-num-bigint-0.4.6
        rust-num-complex-0.4.6
        rust-num-conv-0.2.2
        rust-num-integer-0.1.46
        rust-num-iter-0.1.45
        rust-num-rational-0.4.2
        rust-num-traits-0.2.19
        rust-num_enum-0.7.6
        rust-num_enum_derive-0.7.6
        rust-objc2-0.6.4
        rust-objc2-app-kit-0.3.2
        rust-objc2-cloud-kit-0.3.2
        rust-objc2-core-data-0.3.2
        rust-objc2-core-foundation-0.3.2
        rust-objc2-core-graphics-0.3.2
        rust-objc2-core-image-0.3.2
        rust-objc2-core-location-0.3.2
        rust-objc2-core-text-0.3.2
        rust-objc2-encode-4.1.0
        rust-objc2-exception-helper-0.1.1
        rust-objc2-foundation-0.3.2
        rust-objc2-io-surface-0.3.2
        rust-objc2-quartz-core-0.3.2
        rust-objc2-ui-kit-0.3.2
        rust-objc2-user-notifications-0.3.2
        rust-objc2-web-kit-0.3.2
        rust-once_cell-1.21.4
        rust-open-5.3.5
        rust-openssl-0.10.81
        rust-openssl-macros-0.1.1
        rust-openssl-probe-0.2.1
        rust-openssl-sys-0.9.117
        rust-option-ext-0.2.0
        rust-ordered-stream-0.2.0
        rust-pango-0.18.3
        rust-pango-sys-0.18.0
        rust-parking-2.2.1
        rust-parking_lot-0.12.5
        rust-parking_lot_core-0.9.12
        rust-pathdiff-0.2.3
        rust-pbkdf2-0.13.0
        rust-percent-encoding-2.3.2
        rust-phf-0.13.1
        rust-phf_codegen-0.13.1
        rust-phf_generator-0.13.1
        rust-phf_macros-0.13.1
        rust-phf_shared-0.13.1
        rust-pin-project-lite-0.2.17
        rust-piper-0.2.5
        rust-pkg-config-0.3.33
        rust-plist-1.9.0
        rust-png-0.17.16
        rust-png-0.18.1
        rust-polling-3.11.0
        rust-potential_utf-0.1.5
        rust-powerfmt-0.2.0
        rust-ppv-lite86-0.2.21
        rust-precomputed-hash-0.1.1
        rust-prettyplease-0.2.37
        rust-proc-macro-crate-1.3.1
        rust-proc-macro-crate-2.0.2
        rust-proc-macro-crate-3.5.0
        rust-proc-macro-error-1.0.4
        rust-proc-macro-error-attr-1.0.4
        rust-proc-macro2-1.0.106
        rust-quick-xml-0.39.4
        rust-quote-1.0.45
        rust-r-efi-5.3.0
        rust-r-efi-6.0.0
        rust-rand-0.8.6
        rust-rand-0.9.5
        rust-rand_chacha-0.3.1
        rust-rand_chacha-0.9.0
        rust-rand_core-0.6.4
        rust-rand_core-0.9.5
        rust-raw-window-handle-0.6.2
        rust-redox_syscall-0.5.18
        rust-redox_users-0.4.6
        rust-redox_users-0.5.2
        rust-ref-cast-1.0.25
        rust-ref-cast-impl-1.0.25
        rust-regex-1.12.4
        rust-regex-automata-0.4.14
        rust-regex-syntax-0.8.11
        rust-reqwest-0.12.28
        rust-reqwest-0.13.4
        rust-rfd-0.16.0
        rust-ring-0.17.14
        rust-rustc-hash-2.1.2
        rust-rustc_version-0.4.1
        rust-rustix-1.1.4
        rust-rustls-0.23.46
        rust-rustls-pki-types-1.14.1
        rust-rustls-webpki-0.103.16
        rust-rustversion-1.0.22
        rust-ryu-1.0.23
        rust-same-file-1.0.6
        rust-schannel-0.1.29
        rust-schemars-0.8.22
        rust-schemars-0.9.0
        rust-schemars-1.2.1
        rust-schemars_derive-0.8.22
        rust-scopeguard-1.2.0
        rust-secret-service-4.0.0
        rust-security-framework-2.11.1
        rust-security-framework-3.7.0
        rust-security-framework-sys-2.17.0
        rust-selectors-0.36.1
        rust-semver-1.0.28
        rust-serde-1.0.228
        rust-serde-untagged-0.1.9
        rust-serde_core-1.0.228
        rust-serde_derive-1.0.228
        rust-serde_derive_internals-0.29.1
        rust-serde_json-1.0.150
        rust-serde_repr-0.1.20
        rust-serde_spanned-0.6.9
        rust-serde_spanned-1.1.1
        rust-serde_urlencoded-0.7.1
        rust-serde_with-3.21.0
        rust-serde_with_macros-3.21.0
        rust-serialize-to-javascript-0.1.2
        rust-serialize-to-javascript-impl-0.1.2
        rust-servo_arc-0.4.3
        rust-sha1-0.10.6
        rust-sha1-0.11.0
        rust-sha2-0.10.9
        rust-sha2-0.11.1
        rust-sharded-slab-0.1.7
        rust-shlex-2.0.1
        rust-signal-hook-registry-1.4.8
        rust-simd-adler32-0.3.9
        rust-siphasher-1.0.3
        rust-slab-0.4.12
        rust-smallvec-1.15.2
        rust-socket2-0.6.4
        rust-softbuffer-0.4.8
        rust-soup3-0.5.0
        rust-soup3-sys-0.5.0
        rust-specta-2.0.0-rc.25
        rust-specta-macros-2.0.0-rc.25
        rust-specta-serde-0.0.12
        rust-specta-typescript-0.0.12
        rust-stable_deref_trait-1.2.1
        rust-static_assertions-1.1.0
        rust-string_cache-0.9.0
        rust-string_cache_codegen-0.6.1
        rust-strsim-0.11.1
        rust-subtle-2.6.1
        rust-swift-rs-1.0.7
        rust-symlink-0.1.0
        rust-syn-1.0.109
        rust-syn-2.0.117
        rust-syn-3.0.6
        rust-sync_wrapper-1.0.2
        rust-synstructure-0.13.2
        rust-system-configuration-0.7.0
        rust-system-configuration-sys-0.6.0
        rust-system-deps-6.2.2
        rust-tao-0.35.3
        rust-tao-macros-0.1.3
        rust-target-lexicon-0.12.16
        rust-tauri-2.11.2
        rust-tauri-build-2.6.2
        rust-tauri-codegen-2.6.2
        rust-tauri-macros-2.6.2
        rust-tauri-plugin-2.6.2
        rust-tauri-plugin-dialog-2.7.1
        rust-tauri-plugin-fs-2.5.1
        rust-tauri-plugin-notification-2.3.3
        rust-tauri-plugin-opener-2.5.4
        rust-tauri-plugin-single-instance-2.4.4
        rust-tauri-plugin-window-state-2.4.1
        rust-tauri-runtime-2.11.2
        rust-tauri-runtime-wry-2.11.2
        rust-tauri-utils-2.9.2
        rust-tauri-winres-0.3.6
        rust-tauri-winrt-notification-0.7.3
        rust-tempfile-3.27.0
        rust-tendril-0.5.0
        rust-thiserror-1.0.69
        rust-thiserror-2.0.18
        rust-thiserror-impl-1.0.69
        rust-thiserror-impl-2.0.18
        rust-thread_local-1.1.10
        rust-time-0.3.49
        rust-time-core-0.1.9
        rust-time-macros-0.2.29
        rust-tinystr-0.8.3
        rust-tinyvec-1.11.0
        rust-tinyvec_macros-0.1.1
        rust-tokio-1.54.1
        rust-tokio-macros-2.7.0
        rust-tokio-native-tls-0.3.1
        rust-tokio-rustls-0.26.4
        rust-tokio-tungstenite-0.24.0
        rust-tokio-util-0.7.18
        rust-toml-0.8.2
        rust-toml-0.9.12-spec-1.1.0
        rust-toml-1.1.2-spec-1.1.0
        rust-toml_datetime-0.6.3
        rust-toml_datetime-0.7.5-spec-1.1.0
        rust-toml_datetime-1.1.1-spec-1.1.0
        rust-toml_edit-0.19.15
        rust-toml_edit-0.20.2
        rust-toml_edit-0.25.12-spec-1.1.0
        rust-toml_parser-1.1.2-spec-1.1.0
        rust-toml_writer-1.1.1-spec-1.1.0
        rust-tower-0.5.3
        rust-tower-http-0.6.11
        rust-tower-layer-0.3.3
        rust-tower-service-0.3.3
        rust-tracing-0.1.44
        rust-tracing-appender-0.2.5
        rust-tracing-attributes-0.1.31
        rust-tracing-core-0.1.36
        rust-tracing-log-0.2.0
        rust-tracing-subscriber-0.3.23
        rust-tray-icon-0.23.1
        rust-try-lock-0.2.5
        rust-tungstenite-0.24.0
        rust-typed-path-0.12.3
        rust-typeid-1.0.3
        rust-typenum-1.20.1
        rust-uds_windows-1.2.1
        rust-unic-char-property-0.9.0
        rust-unic-char-range-0.9.0
        rust-unic-common-0.9.0
        rust-unic-ucd-ident-0.9.0
        rust-unic-ucd-version-0.9.0
        rust-unicase-2.9.0
        rust-unicode-ident-1.0.24
        rust-unicode-segmentation-1.13.3
        rust-unicode-xid-0.2.6
        rust-untrusted-0.9.0
        rust-url-2.5.8
        rust-urlpattern-0.3.0
        rust-utf-8-0.7.6
        rust-utf8_iter-1.0.4
        rust-uuid-1.23.3
        rust-valuable-0.1.1
        rust-vcpkg-0.2.15
        rust-version-compare-0.2.1
        rust-version_check-0.9.5
        rust-vswhom-0.1.0
        rust-vswhom-sys-0.1.3
        rust-walkdir-2.5.0
        rust-want-0.3.1
        rust-wasi-0.11.1-wasi-snapshot-preview1
        rust-wasip2-1.0.4-wasi-0.2.12
        rust-wasip3-0.4.0-wasi-0.3.0-rc-2026-01-06
        rust-wasm-bindgen-0.2.125
        rust-wasm-bindgen-futures-0.4.75
        rust-wasm-bindgen-macro-0.2.125
        rust-wasm-bindgen-macro-support-0.2.125
        rust-wasm-bindgen-shared-0.2.125
        rust-wasm-encoder-0.244.0
        rust-wasm-metadata-0.244.0
        rust-wasm-streams-0.4.2
        rust-wasm-streams-0.5.0
        rust-wasmparser-0.244.0
        rust-web-sys-0.3.102
        rust-web_atoms-0.2.4
        rust-webkit2gtk-2.0.2
        rust-webkit2gtk-sys-2.0.2
        rust-webview2-com-0.38.2
        rust-webview2-com-macros-0.8.1
        rust-webview2-com-sys-0.38.2
        rust-winapi-0.3.9
        rust-winapi-i686-pc-windows-gnu-0.4.0
        rust-winapi-util-0.1.11
        rust-winapi-x86_64-pc-windows-gnu-0.4.0
        rust-window-vibrancy-0.6.0
        rust-windows-0.61.3
        rust-windows-collections-0.2.0
        rust-windows-core-0.61.2
        rust-windows-core-0.62.2
        rust-windows-future-0.2.1
        rust-windows-implement-0.60.2
        rust-windows-interface-0.59.3
        rust-windows-link-0.1.3
        rust-windows-link-0.2.1
        rust-windows-numerics-0.2.0
        rust-windows-registry-0.6.1
        rust-windows-result-0.3.4
        rust-windows-result-0.4.1
        rust-windows-strings-0.4.2
        rust-windows-strings-0.5.1
        rust-windows-sys-0.45.0
        rust-windows-sys-0.48.0
        rust-windows-sys-0.52.0
        rust-windows-sys-0.59.0
        rust-windows-sys-0.60.2
        rust-windows-sys-0.61.2
        rust-windows-targets-0.42.2
        rust-windows-targets-0.48.5
        rust-windows-targets-0.52.6
        rust-windows-targets-0.53.5
        rust-windows-threading-0.1.0
        rust-windows-version-0.1.7
        rust-windows_aarch64_gnullvm-0.42.2
        rust-windows_aarch64_gnullvm-0.48.5
        rust-windows_aarch64_gnullvm-0.52.6
        rust-windows_aarch64_gnullvm-0.53.1
        rust-windows_aarch64_msvc-0.42.2
        rust-windows_aarch64_msvc-0.48.5
        rust-windows_aarch64_msvc-0.52.6
        rust-windows_aarch64_msvc-0.53.1
        rust-windows_i686_gnu-0.42.2
        rust-windows_i686_gnu-0.48.5
        rust-windows_i686_gnu-0.52.6
        rust-windows_i686_gnu-0.53.1
        rust-windows_i686_gnullvm-0.52.6
        rust-windows_i686_gnullvm-0.53.1
        rust-windows_i686_msvc-0.42.2
        rust-windows_i686_msvc-0.48.5
        rust-windows_i686_msvc-0.52.6
        rust-windows_i686_msvc-0.53.1
        rust-windows_x86_64_gnu-0.42.2
        rust-windows_x86_64_gnu-0.48.5
        rust-windows_x86_64_gnu-0.52.6
        rust-windows_x86_64_gnu-0.53.1
        rust-windows_x86_64_gnullvm-0.42.2
        rust-windows_x86_64_gnullvm-0.48.5
        rust-windows_x86_64_gnullvm-0.52.6
        rust-windows_x86_64_gnullvm-0.53.1
        rust-windows_x86_64_msvc-0.42.2
        rust-windows_x86_64_msvc-0.48.5
        rust-windows_x86_64_msvc-0.52.6
        rust-windows_x86_64_msvc-0.53.1
        rust-winnow-0.5.40
        rust-winnow-0.7.15
        rust-winnow-1.0.3
        rust-winreg-0.55.0
        rust-wit-bindgen-0.51.0
        rust-wit-bindgen-0.57.1
        rust-wit-bindgen-core-0.51.0
        rust-wit-bindgen-rust-0.51.0
        rust-wit-bindgen-rust-macro-0.51.0
        rust-wit-component-0.244.0
        rust-wit-parser-0.244.0
        rust-writeable-0.6.3
        rust-wry-0.55.1
        rust-x11-2.21.0
        rust-x11-dl-2.21.0
        rust-xdg-home-1.3.0
        rust-yoke-0.8.3
        rust-yoke-derive-0.8.2
        rust-zbus-4.4.0
        rust-zbus-5.18.0
        rust-zbus_macros-4.4.0
        rust-zbus_macros-5.18.0
        rust-zbus_names-3.0.0
        rust-zbus_names-4.3.4
        rust-zerocopy-0.8.52
        rust-zerocopy-derive-0.8.52
        rust-zerofrom-0.1.8
        rust-zerofrom-derive-0.1.7
        rust-zeroize-1.9.0
        rust-zeroize_derive-1.5.0
        rust-zerotrie-0.2.4
        rust-zerovec-0.11.6
        rust-zerovec-derive-0.11.3
        rust-zip-9.0.4
        rust-zlib-rs-0.6.8
        rust-zmij-1.0.21
        rust-zopfli-0.8.3
        rust-zstd-0.14.3
        rust-zstd-safe-8.2.0
        rust-zstd-sys-2.1.2-zstd.1.5.7
        rust-zvariant-4.2.0
        rust-zvariant-5.13.1
        rust-zvariant_derive-4.2.0
        rust-zvariant_derive-5.13.1
        rust-zvariant_utils-2.1.0
        rust-zvariant_utils-3.5.0))
