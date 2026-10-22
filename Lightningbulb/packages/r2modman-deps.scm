;;; GENERATED FILE -- do not edit by hand.
;;; Regenerate with contrib/pnpm-lock-to-guix.py when the upstream lockfile
;;; changes.

;;; npm registry tarballs from the upstream pnpm-lock.yaml, restricted to what
;;; installs on x86_64-linux.  Each entry is (REGISTRY-PATH . ORIGIN); see
;;; (Lightningbulb packages js-offline).

(define-module (Lightningbulb packages r2modman-deps)
  #:use-module (Lightningbulb packages js-offline)
  #:export (r2modman-npm-tarballs
            r2modman-pnpm-tarball))

(define r2modman-npm-tarballs
  (list (npm-tarball "7zip-bin/-/7zip-bin-5.2.0.tgz"
                     "0zaafri0x1vx8xc41dzq2xxi3dg4wslm8qnhym9vxs0bw2777y84")
        (npm-tarball "@babel/code-frame/-/code-frame-7.29.0.tgz"
                     "180cm49p4zjy0i3blv8vbv6dnwh4bhg99i85361zndc8xkyj3nd4")
        (npm-tarball "@babel/compat-data/-/compat-data-7.29.0.tgz"
                     "0v1lvn3lkxpgccv75w0qkfwnwd6b3f5n7f99ay8mi8j5vd0phg6a")
        (npm-tarball "@babel/core/-/core-7.29.0.tgz"
                     "09y3z5va94z31sv9d2x9ncgbfychjh22jwy58v9lr0xy6fvh4qqj")
        (npm-tarball "@babel/generator/-/generator-7.29.1.tgz"
                     "15pdrsr0g772jmlajb6lawsgww1a1iv3ymfz5grq7cgw7h5n7gi2")
        (npm-tarball "@babel/helper-annotate-as-pure/-/helper-annotate-as-pure-7.27.3.tgz"
                     "06i5ls30qvdmcb57rw95sli4qnb7n6r7v25xnagqsmvwgqvh67fv")
        (npm-tarball "@babel/helper-compilation-targets/-/helper-compilation-targets-7.28.6.tgz"
                     "11jdalnanbx4yr7w7acjjdpd2yn4gj5lgfmhv82wm2f511y9b2a5")
        (npm-tarball "@babel/helper-create-class-features-plugin/-/helper-create-class-features-plugin-7.28.6.tgz"
                     "1p13khl7x9icbjr4ys91wxd0i7xb53s49v1j9a41gw9vjh3yb0bj")
        (npm-tarball "@babel/helper-globals/-/helper-globals-7.28.0.tgz"
                     "196hdkvkr5m8afkvfvxq17k3rbgvg0wq5picb6vk0qj3dv7yy91i")
        (npm-tarball "@babel/helper-member-expression-to-functions/-/helper-member-expression-to-functions-7.28.5.tgz"
                     "1jjhk7dp6fik35lbmgb1lw0kpb8pa32410il76zcs9bhgwap66y6")
        (npm-tarball "@babel/helper-module-imports/-/helper-module-imports-7.28.6.tgz"
                     "01km7lf7jh8whd3ahbif4n7xgab5kfdx5sv8awhr8czi75jhk0ih")
        (npm-tarball "@babel/helper-module-transforms/-/helper-module-transforms-7.28.6.tgz"
                     "1l93b05q6k4k4hwwxbvrf0vwl3grh32ypw0hnv5dicmmzdwg2h7l")
        (npm-tarball "@babel/helper-optimise-call-expression/-/helper-optimise-call-expression-7.27.1.tgz"
                     "042k579cwyc21vjjwgzd4771cjcqix1kiqjis6ciksz0hc34kx23")
        (npm-tarball "@babel/helper-plugin-utils/-/helper-plugin-utils-7.28.6.tgz"
                     "031cqalrwbwgfykz7d9yi3qvw797s018p6scafnaqgjv77054hld")
        (npm-tarball "@babel/helper-replace-supers/-/helper-replace-supers-7.28.6.tgz"
                     "115dxswyq6301kmdlrjrh7b6xscqwgxfwp27gpy948chxhwk53il")
        (npm-tarball "@babel/helper-skip-transparent-expression-wrappers/-/helper-skip-transparent-expression-wrappers-7.27.1.tgz"
                     "0ap07f36iyp1na0gg8824qksy605wjnqgppp4sdw3jfcffrl33aw")
        (npm-tarball "@babel/helper-string-parser/-/helper-string-parser-7.27.1.tgz"
                     "1l8ljy2p90gdrwdnvbzb4wi5x901xksjfgiwjslm3ifyhr85s456")
        (npm-tarball "@babel/helper-validator-identifier/-/helper-validator-identifier-7.28.5.tgz"
                     "1mfy0jq815jbg68qkbg80jgxl7qicg5q0v4dkj31d3766bk13356")
        (npm-tarball "@babel/helper-validator-option/-/helper-validator-option-7.27.1.tgz"
                     "0kd2j4zahqp6dilgr4zh9l2qkbwp45csanifhwgfmdyrv9cmgan3")
        (npm-tarball "@babel/helpers/-/helpers-7.29.2.tgz"
                     "04sq6wqkyz9aljca12f5ys6i3p4i8jpa4k6p1zxh586si5sdkdzd")
        (npm-tarball "@babel/parser/-/parser-7.29.2.tgz"
                     "1h4gds67ihilpsbikb73zqsr9nvb1ppi68vijb1gqpyg1166cmrf")
        (npm-tarball "@babel/plugin-syntax-jsx/-/plugin-syntax-jsx-7.28.6.tgz"
                     "021kcy1panqhvvh221373q3gv7jy7v61x6bndmir9wx0mvmzm9pc")
        (npm-tarball "@babel/plugin-syntax-typescript/-/plugin-syntax-typescript-7.28.6.tgz"
                     "0f86dhr4w1fspf5b1avbjsjyc9sxpz1bbnsx2mkbaybng8w3cpmm")
        (npm-tarball "@babel/plugin-transform-modules-commonjs/-/plugin-transform-modules-commonjs-7.28.6.tgz"
                     "1xi7a0ffbzhjkhmfivbp5afmpql7b11cbspdc8wjb8g3kvpgn960")
        (npm-tarball "@babel/plugin-transform-typescript/-/plugin-transform-typescript-7.28.6.tgz"
                     "0p8vhcfs5szbl3l8abm3c5b4kjnzw65zfbrn1j6zk70y2nwi6xnf")
        (npm-tarball "@babel/preset-typescript/-/preset-typescript-7.28.5.tgz"
                     "18si7q83gccs3c23y0hbzgr3fz5nr73bkfldjc1i6y9c945r6sfm")
        (npm-tarball "@babel/template/-/template-7.28.6.tgz"
                     "0w506nn3gm68jlc05dpshbpyvwaqh1shpqs3jjmh9linpbw12jdh")
        (npm-tarball "@babel/traverse/-/traverse-7.29.0.tgz"
                     "08bjsczvv425mkgyl70663cr9qrjp4rr3l12gb1rrrkvxp52j4a3")
        (npm-tarball "@babel/types/-/types-7.29.0.tgz"
                     "1jz11xymmd62f30pbkf7ph5275hz8k58014rrmkkh6qsb2cz9rcw")
        (npm-tarball "@bufbuild/protobuf/-/protobuf-2.11.0.tgz"
                     "0bbcccyh4c0s0iv6shrwl4189nyjgg4wvf8arwifm583msf9b9i5")
        (npm-tarball "@electron/asar/-/asar-3.4.1.tgz"
                     "00k1g51cz2wxccr5zpiz5gfq8h4z5r8h8brq2dwwa5z6mm9cxrn4")
        (npm-tarball "@electron/asar/-/asar-4.1.1.tgz"
                     "19wq5cghpr1ndr0fdh2agi364paavrz2j5wpv36dyksvz4sv3q0y")
        (npm-tarball "@electron/fuses/-/fuses-1.8.0.tgz"
                     "0jz7mcw0phfrg1avi8s22w4lkai9mdcqr11qmcdx3351x52phy3y")
        (npm-tarball "@electron/get/-/get-2.0.3.tgz"
                     "1lxr90sjfdsdd022rzk3mxzc97slkiqg0k8ij1iw13q44v608dx5")
        (npm-tarball "@electron/get/-/get-3.1.0.tgz"
                     "0f7v1nbzy849g5i17554qyvsmplxfwk0ylf8y59bc8q9hc6wqq6c")
        (npm-tarball "@electron/notarize/-/notarize-2.5.0.tgz"
                     "1mxpp646bbvrygjh3jj7s2hm39zrzxyxv4lx3pgwsw3gchb9fxwf")
        (npm-tarball "@electron/osx-sign/-/osx-sign-1.3.3.tgz"
                     "0s5zi550c22ql2jmy8cyb1zwvh9yrbfmx4cbpmhdk0g624h4jd4v")
        (npm-tarball "@electron/rebuild/-/rebuild-4.0.3.tgz"
                     "19z30mnflw4np5v727am3907vdkcw016dhdnjhzi4dzzmgizcmdh")
        (npm-tarball "@electron/universal/-/universal-2.0.3.tgz"
                     "12zgxqqd0x73r2vx7j8lhm9hh3nzyf5g3q8yfl5m6xysk2fnrjr0")
        (npm-tarball "@electron/windows-sign/-/windows-sign-1.2.2.tgz"
                     "1jb9hgdnr8ig0sq3g9x1gqaispsfx1bpjqsflzyvnx0jxlq9nydc")
        (npm-tarball "@emnapi/core/-/core-1.9.1.tgz"
                     "00ihn4spgsa5fr88jzn00aavkhbk1r82ki783xd93kvzd30g8z7x")
        (npm-tarball "@emnapi/runtime/-/runtime-1.9.1.tgz"
                     "135vhrfn7qwzxzl04sky93maq8c33yha4jymfn3av847yj70n2aj")
        (npm-tarball "@emnapi/wasi-threads/-/wasi-threads-1.2.0.tgz"
                     "13rgabb3mjhqpdqdrhsl5j1f910i2dcv2gmj3hjwy10s7dbqhgzv")
        (npm-tarball "@esbuild/linux-x64/-/linux-x64-0.27.4.tgz"
                     "134njg7mk3pzbl9vnf1pjsg9hhbz9xjm56wsncn5m81d7lvjxwlm")
        (npm-tarball "@floating-ui/core/-/core-1.7.5.tgz"
                     "164grm7nmjkcrbc14zzvj33bqpn7k2n6d3c7mb5g6mspy74l4v24")
        (npm-tarball "@floating-ui/dom/-/dom-1.1.1.tgz"
                     "1pzjvfznm5h3rcvk7pj7rz1ivxqkpr2h3z2xbhn4n8ssmprqrk22")
        (npm-tarball "@floating-ui/utils/-/utils-0.2.11.tgz"
                     "1lghjkclq6c9as8k5qxvba4jjhlg4g31hc4jn7f35hk7b1y40069")
        (npm-tarball "@glideapps/ts-necessities/-/ts-necessities-2.2.3.tgz"
                     "1k814q55jvz06fngrwskyydrn87527j1dviagnpkiarnam34dq52")
        (npm-tarball "@inquirer/ansi/-/ansi-2.0.4.tgz"
                     "1dbbdr9ry0plsz6zddwi24rpz30ynw5g8pc7ppay5j82bhixhbb5")
        (npm-tarball "@inquirer/checkbox/-/checkbox-5.1.2.tgz"
                     "1n9v5j9w4cj0zgbdm9c9j8snyrq3ccma1k906x8h7a2b6pd8r793")
        (npm-tarball "@inquirer/confirm/-/confirm-6.0.10.tgz"
                     "1rpvq67q12d7189xcmk81nfrjvsb8q9kvgamz54ww52p0ij64qr6")
        (npm-tarball "@inquirer/core/-/core-11.1.7.tgz"
                     "09hqqm9hyy0bj71fra0rmmc5zy39i7fvqxpnf88q2l7sw2fzkalr")
        (npm-tarball "@inquirer/editor/-/editor-5.0.10.tgz"
                     "17izsmf12i6f2vf63xvrj4k2khqr549aa4v3lvg085kmsgg3v7v9")
        (npm-tarball "@inquirer/expand/-/expand-5.0.10.tgz"
                     "1majr13mmij0ac1lsiv7mm5nh8asr1xfdba1fq4z39sbq979fvjm")
        (npm-tarball "@inquirer/external-editor/-/external-editor-2.0.4.tgz"
                     "1sgsj1f8cj0cg1s3fnmdycvgs56ps1mn2kmvjz65spj1wd8lslw5")
        (npm-tarball "@inquirer/figures/-/figures-2.0.4.tgz"
                     "00mnas9r208vd7afm3xssazcr6bva2i8m1brqzlsakpxf0746drk")
        (npm-tarball "@inquirer/input/-/input-5.0.10.tgz"
                     "09d5n83bp7z3ksb80c9d6almk9yfwbdf6sjqhiz27fwyh610ih7x")
        (npm-tarball "@inquirer/number/-/number-4.0.10.tgz"
                     "1d5jdn1z6lha77hj4pa4wfacf2rvk202cr3ckz3g96pnrnfgmz1f")
        (npm-tarball "@inquirer/password/-/password-5.0.10.tgz"
                     "1dpfc5rb8dhl8mf3j3w8anvp9ywbylg620fbfnw20pyvqdl14cg2")
        (npm-tarball "@inquirer/prompts/-/prompts-8.3.2.tgz"
                     "0xmkrfy5cja4ygwx3rrrf99snnwgxm97nx3l7sz53sg6nld3cfdk")
        (npm-tarball "@inquirer/rawlist/-/rawlist-5.2.6.tgz"
                     "0a5qdrfsk2x1dkbl2syps1jakjsxbraf9i9rvmb9vm7vd3spc51q")
        (npm-tarball "@inquirer/search/-/search-4.1.6.tgz"
                     "0qqqv80wbf0jih6zsl7r6b3scfn158szw9svcivq7wbmckvk9208")
        (npm-tarball "@inquirer/select/-/select-5.1.2.tgz"
                     "0cw2xp0iihl6crjp0zjxyhn4fjdvyb659i25dh7rk8cvrrf4l71b")
        (npm-tarball "@inquirer/type/-/type-4.0.4.tgz"
                     "14xvf9qnskh4qaw15pqy8y3sdwqjfhbxr81vi0wfbgafhhvcqyl3")
        (npm-tarball "@intlify/core-base/-/core-base-11.3.0.tgz"
                     "1p3i3rnfab22c4n3p5v5mddajhl3b8l4a66wn89p3kxg5rsjxlih")
        (npm-tarball "@intlify/devtools-types/-/devtools-types-11.3.0.tgz"
                     "0i11z5j3kcfrzdz5kd5hx11vc0l9jmsj0pb5ynrwd8w8gv9hiah9")
        (npm-tarball "@intlify/message-compiler/-/message-compiler-11.3.0.tgz"
                     "0grd1nz7qpvvc8fwqdc99bvh7jg5n7gqqpn45spfnnrwslj7zbj3")
        (npm-tarball "@intlify/shared/-/shared-11.3.0.tgz"
                     "1s1p6r8qdkg6z5vphg8chwkp6hy3ncbg7hylfc8wzbzp88f27m0y")
        (npm-tarball "@isaacs/cliui/-/cliui-8.0.2.tgz"
                     "1hp481vmgcbn91byd6iyrf2qm0a2wyb9qg127jkhknq9zil3rbim")
        (npm-tarball "@isaacs/fs-minipass/-/fs-minipass-4.0.1.tgz"
                     "0dl2v4741w4lj36m2yg1h8qpvfbbxyfh7qkr1scah7ncrkiqdhks")
        (npm-tarball "@jridgewell/gen-mapping/-/gen-mapping-0.3.13.tgz"
                     "10h05zv5qcbxiz5wslzqv1aik7zl0cfqiarqhw63xmpnq5cgc5mw")
        (npm-tarball "@jridgewell/remapping/-/remapping-2.3.5.tgz"
                     "00hssw2k05fxp4fgjk9182bgynx2b4slfcvwwir6dlcslf16gcbh")
        (npm-tarball "@jridgewell/resolve-uri/-/resolve-uri-3.1.2.tgz"
                     "0c72fqvljvr28rdmg6hjd8zc63vm00r9xlrx6l9spfjq4pvgjlnv")
        (npm-tarball "@jridgewell/source-map/-/source-map-0.3.11.tgz"
                     "1r9wkmbpl136qyqkza35x1j03akm0pri3f9k8cajn80awyk1a880")
        (npm-tarball "@jridgewell/sourcemap-codec/-/sourcemap-codec-1.5.5.tgz"
                     "11b5h4hihb2n8203znalqm53s7pv82a84jahsqgf7rd2406kpba7")
        (npm-tarball "@jridgewell/trace-mapping/-/trace-mapping-0.3.31.tgz"
                     "1krw8nqmca9k4gb20kh9mpfsjb2b6ggrx226haz5l3b336hp2k66")
        (npm-tarball "@malept/cross-spawn-promise/-/cross-spawn-promise-2.0.0.tgz"
                     "1fnjkqd3wawnnghhwsa01wy9n920g7hwxw5qb2239fh8lfzinzbr")
        (npm-tarball "@malept/flatpak-bundler/-/flatpak-bundler-0.4.0.tgz"
                     "1iipi2r4bhpikb8s37jxarpc7g3iypc6a6gvv6hkwq0pr44kpv8v")
        (npm-tarball "@napi-rs/wasm-runtime/-/wasm-runtime-1.1.1.tgz"
                     "1wxcibcdx2rgk1lid7jq0i7ik7gwwrnkq8xmys029nfspy9zq5zv")
        (npm-tarball "@noble/hashes/-/hashes-1.4.0.tgz"
                     "0fgckf0dqr21wpj70fj8cljx5ndngj4kbw6iksqygjcmj2nscpy5")
        (npm-tarball "@noble/hashes/-/hashes-2.2.0.tgz"
                     "01j6cl7bsy6xramab7919lz8z0hwlbmqk3yf1vx4arpkgayki2q1")
        (npm-tarball "@node-steam/vdf/-/vdf-2.2.0.tgz"
                     "1j59p3lgb9wbgab9758clbrx1zy278r4p8nsn0d74264nm7d8fay")
        (npm-tarball "@npmcli/agent/-/agent-3.0.0.tgz"
                     "1faw3b0jxr92wradimgbrsc3i1gwy161s4m5y37yaq1p3l29d6gw")
        (npm-tarball "@npmcli/fs/-/fs-4.0.0.tgz"
                     "1zyjgnqzv2wczn5r8hr54vmmv9da5b0gknrc02f0byy3f03xxbxs")
        (npm-tarball "@one-ini/wasm/-/wasm-0.1.1.tgz"
                     "05kidzxmr1qgabh1wq34v0xwd79fyhgzgwzrxbdp6dkqb0krm4hq")
        (npm-tarball "@oxc-project/types/-/types-0.122.0.tgz"
                     "16ndka63y09a59js3kmgdfifdvmx0zfdgrf8aciz23915faqfq2g")
        (npm-tarball "@parcel/watcher-linux-x64-glibc/-/watcher-linux-x64-glibc-2.5.6.tgz"
                     "0bm4av1wd3yp0sim6pg0qkn8hibvh0z52yfgf8hx6cvvdksx5vj3")
        (npm-tarball "@parcel/watcher-linux-x64-musl/-/watcher-linux-x64-musl-2.5.6.tgz"
                     "09ivqcz0wsl9mr6flvx6nz6d76ggs1jzl1brnyl6mni4skixibq5")
        (npm-tarball "@parcel/watcher/-/watcher-2.5.6.tgz"
                     "0j1n8paikcrx3w4fbnz9ihdqq407ryphg40prvmhpqg7ps2p5ald")
        (npm-tarball "@peculiar/asn1-cms/-/asn1-cms-2.6.1.tgz"
                     "05hgjfvplif4pvxcr4b2873csfi2frcrz03x6fandq3a230khb4c")
        (npm-tarball "@peculiar/asn1-csr/-/asn1-csr-2.6.1.tgz"
                     "1hgwhnkyfxij11j9mwvjimi16qvrq9v03psvglr1id35s70kykim")
        (npm-tarball "@peculiar/asn1-ecc/-/asn1-ecc-2.6.1.tgz"
                     "11xagr5zxwsk406g4svhl5a234fjday8775gk8w8kir2q7z0zz8j")
        (npm-tarball "@peculiar/asn1-pfx/-/asn1-pfx-2.6.1.tgz"
                     "08k94f7n7aq5ga336g7r3vh3cfiwmsnw7vfgl8p2gp6q03w6w8x2")
        (npm-tarball "@peculiar/asn1-pkcs8/-/asn1-pkcs8-2.6.1.tgz"
                     "1kggx7w17nx0gv2k3pmawbxnf029s6g2dachc02z6bs0msqykcmg")
        (npm-tarball "@peculiar/asn1-pkcs9/-/asn1-pkcs9-2.6.1.tgz"
                     "090vgz4ns5g1pm8s1libhcgf09w8avl5l6dvxf9clsi0iphx7a2f")
        (npm-tarball "@peculiar/asn1-rsa/-/asn1-rsa-2.6.1.tgz"
                     "0b2g5mz7qnxwyhpgd4g00y4cbh75hpf13fxc63f3ynqsv4dpslk0")
        (npm-tarball "@peculiar/asn1-schema/-/asn1-schema-2.6.0.tgz"
                     "05nhqr09rs4lsz2adz1g87i6d49i6pqwmdyxpaazy1g9vpgm853n")
        (npm-tarball "@peculiar/asn1-schema/-/asn1-schema-2.7.0.tgz"
                     "1awmx1dwlm8j944qv5p1lf6fg7ca6crv6hz8aa9qh4vp3ihmadrc")
        (npm-tarball "@peculiar/asn1-x509-attr/-/asn1-x509-attr-2.6.1.tgz"
                     "03rl9c6d8vmlwzvgzaby17dbnj1fscji9fpmh5pf6sdahgndjdrd")
        (npm-tarball "@peculiar/asn1-x509/-/asn1-x509-2.6.1.tgz"
                     "022c22c9r82g5h4c2spzrjfb1q5z8zmmrc62rrv2zar00jrniqsb")
        (npm-tarball "@peculiar/json-schema/-/json-schema-1.1.12.tgz"
                     "0m45jqgd5156rgfpfkd2zdjia6cszzpc4m7ipc7w3p38n7rqkhsk")
        (npm-tarball "@peculiar/utils/-/utils-2.0.3.tgz"
                     "1hmwryzp6ml28r3bbxqsg7crskywmdf82h6z51rz6mlrps6w4fpi")
        (npm-tarball "@peculiar/webcrypto/-/webcrypto-1.7.1.tgz"
                     "0x3bk42r5f1wlsr2f1wsx590jslmj0zxb81x3y9n17v8gl64037z")
        (npm-tarball "@peculiar/x509/-/x509-1.14.3.tgz"
                     "14s8cpyz8v3dmx1sxjvv4x2qnpk9hd9yzpfc9h9nnbvy1pnh7w7z")
        (npm-tarball "@pkgjs/parseargs/-/parseargs-0.11.0.tgz"
                     "09bl6v1rzka8w6ivyzq1i9qbhv4nlkg2ylhnhpgw0aswgznmkcan")
        (npm-tarball "@quasar/app-vite/-/app-vite-2.5.4.tgz"
                     "0qkh6lk98k2w4j6yxr3zaygkqig3xk6lrfq5val3ii2j08h0sr0n")
        (npm-tarball "@quasar/extras/-/extras-1.17.0.tgz"
                     "1xl96n3rd5kwv4394rc0591m859if1687pkdc54m48d0idyrl99c")
        (npm-tarball "@quasar/render-ssr-error/-/render-ssr-error-1.0.4.tgz"
                     "1dd227krn72zcms4848kygc01hyb27iq15569mg1rfgxz5z5n0k1")
        (npm-tarball "@quasar/ssl-certificate/-/ssl-certificate-2.0.0.tgz"
                     "16kqbpkkj4azbkz2hdp17mhifh9igsivi5y1h00zcryaaprz5vsl")
        (npm-tarball "@quasar/vite-plugin/-/vite-plugin-1.11.0.tgz"
                     "1xl1mq0lf7d3a18afkaimhs1shwj06vaapns23a3l474jdzl9p22")
        (npm-tarball "@rolldown/binding-linux-x64-gnu/-/binding-linux-x64-gnu-1.0.0-rc.11.tgz"
                     "1dg7fpm3mz40f0g2na90b72mqphjszlv3j0v10mb9w47rhxfg90j")
        (npm-tarball "@rolldown/binding-linux-x64-musl/-/binding-linux-x64-musl-1.0.0-rc.11.tgz"
                     "1xll3284qzjpj57l6m6773l2civxqln0iw8wl2ryfqfvfmdz02j6")
        (npm-tarball "@rolldown/pluginutils/-/pluginutils-1.0.0-rc.11.tgz"
                     "05kf4xm7yc04y9a41ljcjvqvwsr6sqspcdk30lzf48zrjs2fbjpk")
        (npm-tarball "@rolldown/pluginutils/-/pluginutils-1.0.0-rc.2.tgz"
                     "07lrsbm9xvd7n7m1wqxz0ms1f71q4axcds9qd583j0s4qy8yvnrf")
        (npm-tarball "@rollup/plugin-inject/-/plugin-inject-5.0.5.tgz"
                     "0zjbg5g4c35s8m3fra1fwhkqmhzg1pn7s1d7q7kfvdh50kym7wxi")
        (npm-tarball "@rollup/pluginutils/-/pluginutils-5.3.0.tgz"
                     "13c6fpfmvrcrzbiia8h675p95lgw2wmf0xd50v95vf1yrvi7gszm")
        (npm-tarball "@rollup/rollup-linux-x64-gnu/-/rollup-linux-x64-gnu-4.60.0.tgz"
                     "1pxm3cii4vjjnqd6f64fdq7v8b2ck2c85v9s3fzv9hhplrv9f6ai")
        (npm-tarball "@rollup/rollup-linux-x64-musl/-/rollup-linux-x64-musl-4.60.0.tgz"
                     "0hnp23cfg2g5nnc7a4sy5i4dp7w3i4cvf3w5zjy9nhb7kssai97x")
        (npm-tarball "@sec-ant/readable-stream/-/readable-stream-0.4.1.tgz"
                     "19jxad9wmfj36zyvpick8wdb6hrnzx9r4w893gqgvrrqd54xhm7w")
        (npm-tarball "@sindresorhus/is/-/is-4.6.0.tgz"
                     "1xr4dqjza7wlh436rkm44ywd00skdjsld343rbrqc6vlh36fqw1r")
        (npm-tarball "@sindresorhus/merge-streams/-/merge-streams-4.0.0.tgz"
                     "1ggy58pn5rwvswrxgn0dkg1brm6md3nkzciqxdc8mplqgzmbpqsn")
        (npm-tarball "@sinonjs/commons/-/commons-1.8.6.tgz"
                     "0f4m1ax6wjizb0pjlvvq5qlsqvbv7fq8r7r9wzxwnvk3x9n6ya6n")
        (npm-tarball "@sinonjs/commons/-/commons-3.0.1.tgz"
                     "0psck61p9v4cd2p4ipg7fi2l0h1xza1365a5f7dmn87rw41n3z1z")
        (npm-tarball "@sinonjs/fake-timers/-/fake-timers-11.3.1.tgz"
                     "1drfl7zwsxny1sp2qk058iv563gv7zzpyh7nzi54zb88ciwcsdzi")
        (npm-tarball "@sinonjs/fake-timers/-/fake-timers-7.1.2.tgz"
                     "1ph7a2l8b2p1yknd5rfyrppqdk08gcvsmipfjy3x6i5y5dnq5zzy")
        (npm-tarball "@sinonjs/samsam/-/samsam-6.1.3.tgz"
                     "1rw0ji5r80crs1wxy6mfn0bm2zlignn1hcvsx68nljhdy54zhccg")
        (npm-tarball "@sinonjs/text-encoding/-/text-encoding-0.7.3.tgz"
                     "004n3mpixw4p2gig671svblbv5z6463147cl57zczq3x2w93m9qg")
        (npm-tarball "@socket.io/component-emitter/-/component-emitter-3.1.2.tgz"
                     "126ch95x4fryy0lyrj1cm7k39m668pigpzhl4x0n75qg4pfw4h13")
        (npm-tarball "@szmarczak/http-timer/-/http-timer-4.0.6.tgz"
                     "0mibapm04v1qka4n0645r5cyrg127cs3j5gdapmpn3c74plgi9zx")
        (npm-tarball "@tybys/wasm-util/-/wasm-util-0.10.1.tgz"
                     "1fyznbqc5cznj67a6njm67cdqn46yq16wc395mw4ji0x13kbvj1d")
        (npm-tarball "@types/adm-zip/-/adm-zip-0.4.34.tgz"
                     "1gig06y3hq8r7sryrw1hy7w5iwwf97hw5966nd6gp0l87za7q568")
        (npm-tarball "@types/async-lock/-/async-lock-1.4.2.tgz"
                     "148nj504np3sdssysl6lx43lgi38cr10ix6hyd7jih7djwa5myxb")
        (npm-tarball "@types/body-parser/-/body-parser-1.19.6.tgz"
                     "12lzx07mh7qljzi01dwlngkcwp1a6i6i67ly7357lln20ff74334")
        (npm-tarball "@types/cacheable-request/-/cacheable-request-6.0.3.tgz"
                     "174gfmvmy7plhy08ph9xwiiwknz5giawdaa5fp65snz7qm9a4d25")
        (npm-tarball "@types/chai/-/chai-4.3.20.tgz"
                     "1p63vynap6q9d03d10p35j94zngc4djwb5ds8zb7vcfnad2bvpn5")
        (npm-tarball "@types/chai/-/chai-5.2.3.tgz"
                     "153zvpnbwgi62h75w9jzcjpayr87af2rnvidk8npvq9q8bim432z")
        (npm-tarball "@types/chrome/-/chrome-0.1.38.tgz"
                     "02rwl2hbasy67g6kz3qdjfrc93c68f7ymy6yv20b2cahgdbpjhi3")
        (npm-tarball "@types/compression/-/compression-1.8.1.tgz"
                     "0jvj35r9spkrkr8af3xx91ksd6lw1anc5z4vzm5pmfdkgl4r5m7k")
        (npm-tarball "@types/connect/-/connect-3.4.38.tgz"
                     "021brsv667i5461bwxb6y0ki52as7cfxx7v0qixhjvf1fl1rbd47")
        (npm-tarball "@types/cordova/-/cordova-11.0.3.tgz"
                     "1gla60saf146rzm1g6pdbp5pbdhgykb0jwxr39rqsy97ir86shw2")
        (npm-tarball "@types/cors/-/cors-2.8.19.tgz"
                     "1103zyiyiyw2mf1xpfgrzcgbr0ld168mlzgsn0h7fbk1mw001lnw")
        (npm-tarball "@types/debug/-/debug-4.1.13.tgz"
                     "1233wm8x719v67fxy36mr4gydpa27jx6lh8xzc3x8ksyw5r8vfqr")
        (npm-tarball "@types/deep-eql/-/deep-eql-4.0.2.tgz"
                     "01rnbz1kbwyrs8bh1ljzqajcbx1d6h82pcb2d6yj68ndy9gihgdn")
        (npm-tarball "@types/estree/-/estree-1.0.8.tgz"
                     "0jnm82j29n0mm527qsz7rv05sksxkgsa92c54f96mnijf7mm611r")
        (npm-tarball "@types/express-serve-static-core/-/express-serve-static-core-5.1.1.tgz"
                     "0ajnqs2mpwslfmvn8r1x2n6iqny6ybdqy3gvhv81651kqv5zzq8l")
        (npm-tarball "@types/express/-/express-5.0.6.tgz"
                     "1g78q28b2b7r0l3k64zbyw1w6aa5q53gffnsqs7v4srnvjhvr2y8")
        (npm-tarball "@types/filesystem/-/filesystem-0.0.36.tgz"
                     "0awbykp4cgsdl29q41mrclfbzl5sgkhbb85h606wc9v0l79w6jy0")
        (npm-tarball "@types/filewriter/-/filewriter-0.0.33.tgz"
                     "1df9wavr2c5is379q87fkxlf2q0cmzfwrkw2qrcrfq97680bsvkl")
        (npm-tarball "@types/fs-extra/-/fs-extra-8.1.5.tgz"
                     "0xmmcbgh9av621xhbfifh2bnv5a0r59jxl7ncpa5xkjn7hqmlilk")
        (npm-tarball "@types/fs-extra/-/fs-extra-9.0.13.tgz"
                     "06m9ma71dpg48kqqwsx1mq4y2r80kfcx3y7cgqkqqzi9183awkik")
        (npm-tarball "@types/har-format/-/har-format-1.2.16.tgz"
                     "1cc5i2kmcr7jif1010hp53hc4c85r1bjqii08b8lx9jlvigyw2vh")
        (npm-tarball "@types/http-cache-semantics/-/http-cache-semantics-4.2.0.tgz"
                     "0si8d9ad5sxflhq7cj292pf3kmmvb79p3awkn0qa158zmpcaswv5")
        (npm-tarball "@types/http-errors/-/http-errors-2.0.5.tgz"
                     "0h6pvcsazq67v0a6lpqhfipbpwvs2kssf7446zhcwwk929wdj2mm")
        (npm-tarball "@types/js-yaml/-/js-yaml-4.0.9.tgz"
                     "1zclc1fwi2kbx4pv81ccalak4awpya7nq9grlk83abpli10j76lc")
        (npm-tarball "@types/jsdom/-/jsdom-21.1.7.tgz"
                     "0fxz0gz7a30v1539g85blffm02ds88sskghjrlw97fxwx6x7dsbf")
        (npm-tarball "@types/keyv/-/keyv-3.1.4.tgz"
                     "0lindx0xh0p57z20y7iylidl3w00dksr02q393h186iva957j732")
        (npm-tarball "@types/lodash.debounce/-/lodash.debounce-4.0.9.tgz"
                     "0k3bwphi0a2wfan17m8akm3z90iiqwipq1g3ldw45hm8bl883kmp")
        (npm-tarball "@types/lodash/-/lodash-4.17.24.tgz"
                     "1a9m5vyqhh6mj01jjgz4v7k392zpfscpcs6iq8bmm3l14dnv4frs")
        (npm-tarball "@types/ms/-/ms-2.1.0.tgz"
                     "02bcrf5p3vdc94byy4pjnaxv7m996m7hivj4bv2xhjz4hi6pnzx0")
        (npm-tarball "@types/node/-/node-20.19.37.tgz"
                     "12agnn4vm25l7yx17smlzwfh8jd848qxfdmw81bbyggspbpw1xf0")
        (npm-tarball "@types/node/-/node-22.19.15.tgz"
                     "0m5pinsnsm7v9r0v408csxxcmfi9nsllskq4rdysbxwm76jz0yh5")
        (npm-tarball "@types/node/-/node-25.5.0.tgz"
                     "106ijmy7jyszjd1f55449hw1vn6cz17ismwl8gyp0dj8n9ffb7hn")
        (npm-tarball "@types/qs/-/qs-6.15.0.tgz"
                     "0w55gi4fyf1284phr6rkzv2cdrs2q93q249l6w20h7iyk6v68b7g")
        (npm-tarball "@types/quill/-/quill-2.0.14.tgz"
                     "02932p4j1zsbdsr5yvy8s0wlybs9z5ivw2h1xrcn1h7q3c89aiiz")
        (npm-tarball "@types/range-parser/-/range-parser-1.2.7.tgz"
                     "1yvjic8r03qnkk1g9v9fq4kwsk95jndivjcns7z0h43lywgm3z62")
        (npm-tarball "@types/responselike/-/responselike-1.0.3.tgz"
                     "0lfhnawymczrpbn8p215hwl3lba2rmxbqfs4fmilnf5m5ifnz3nn")
        (npm-tarball "@types/send/-/send-1.2.1.tgz"
                     "0vmjgbczhbciv5xkgr8qas7q2dyhp836bq6f2fnrdsf91cvs1qbi")
        (npm-tarball "@types/serve-static/-/serve-static-2.2.0.tgz"
                     "08vzx1iw8dvaf6r7zp9qdi15xq4gl4ch4r3dv9rh5ljyzzkldnjv")
        (npm-tarball "@types/sinon/-/sinon-10.0.20.tgz"
                     "0zy0vplqq9krmdqfdkjm4wf2brf0sgvy09ixfg9xapbhqjdhjqcn")
        (npm-tarball "@types/sinonjs__fake-timers/-/sinonjs__fake-timers-15.0.1.tgz"
                     "0yhvfdxz1df5dc29bdkd9dmha1s4mg8y8nshrh2n8m0s3pyqxs5s")
        (npm-tarball "@types/tough-cookie/-/tough-cookie-4.0.5.tgz"
                     "1qywjmvw7cdzjblgapnb1dnhiq5wj2kwbn6s60ms1xh2b3dya9in")
        (npm-tarball "@types/unzipper/-/unzipper-0.10.11.tgz"
                     "0pzl4kbm7xz5j9gcnsb1mfswpd84x6pkk63gbsngwmz3aifzi1d4")
        (npm-tarball "@types/ws/-/ws-8.18.1.tgz"
                     "19ag4l0i8xrldrayhlx8136bq8sci39a4c08jbf1bgr45aan69yw")
        (npm-tarball "@types/yaml/-/yaml-1.9.7.tgz"
                     "0c24bxxv7a6fpliiclz4zk0nykpkg0z9nmbwr53fifjyf96kamab")
        (npm-tarball "@types/yauzl/-/yauzl-2.10.3.tgz"
                     "0y1mkflnfxxrk8vf4a5yxsj4jb6sf7mhgqja39bc8d72k6ylm0xp")
        (npm-tarball "@vitejs/plugin-vue/-/plugin-vue-6.0.5.tgz"
                     "19liq1vv8648z7dv6jsfq1my0y4jq6xlyl2nymkchrq31ra537z0")
        (npm-tarball "@vitest/expect/-/expect-3.2.4.tgz"
                     "1ihjdp85cqmic1h30l46gna3z61xbc6kqdg2flis8cq9a8f9n9fx")
        (npm-tarball "@vitest/mocker/-/mocker-3.2.4.tgz"
                     "0mqr06bx69iffx9bpii99mywqd19li8p8k77x01d6payvd3k3qff")
        (npm-tarball "@vitest/pretty-format/-/pretty-format-3.2.4.tgz"
                     "0mg2lp5377hc6kwmijq5msdhz6r71a707q4prrjv0d9rfslf1q3z")
        (npm-tarball "@vitest/runner/-/runner-3.2.4.tgz"
                     "1m60i3zfn4l6vly4fy4zj4k9604d0c9j1zk0lf3m7c8ng2a0zlnw")
        (npm-tarball "@vitest/snapshot/-/snapshot-3.2.4.tgz"
                     "040fy3db2wzfv6rv2d2zmq9dl384qy4i2ifs4v08r60kb160issj")
        (npm-tarball "@vitest/spy/-/spy-3.2.4.tgz"
                     "01f8r88rhgjdkjvlyp8p18khw8gs57giq1xl02p66jd8863dhc6n")
        (npm-tarball "@vitest/utils/-/utils-3.2.4.tgz"
                     "15d4i8170i3in4b4nyq5dzbkhhzskyf22rk842iwa9rdh1dd9f94")
        (npm-tarball "@volar/language-core/-/language-core-2.4.28.tgz"
                     "11ljrz1wncsl2xb5zx3xamawdb8ffjp812h6gapra6kljzba4d4n")
        (npm-tarball "@volar/source-map/-/source-map-2.4.28.tgz"
                     "19kicv609j8ff1sli2xpw0am793i34cc4g7zmkaay13s00da4g05")
        (npm-tarball "@volar/typescript/-/typescript-2.4.28.tgz"
                     "0sp9bil74n2y35l9hj3pn40232plwnzlr34vd9ij3nk75kmwi7s8")
        (npm-tarball "@vue/compiler-core/-/compiler-core-3.5.31.tgz"
                     "12vrwcvg4h6dndy5alcim31kbllhglq960v6pzdgj1yzkyngkfw9")
        (npm-tarball "@vue/compiler-dom/-/compiler-dom-3.5.31.tgz"
                     "0mq2mrmvx5h7qx5r5xwf0wlp65pj5r16rv3qb02lyn22lxs3m4db")
        (npm-tarball "@vue/compiler-sfc/-/compiler-sfc-3.5.31.tgz"
                     "0b517fdhzdjn40brnh4zpsi4w333vjnjvswp1l90846lk4ry2cj9")
        (npm-tarball "@vue/compiler-ssr/-/compiler-ssr-3.5.31.tgz"
                     "0ibaqgwmnk10bgd6z8yg2piisin2l773lbdvsn07iavywpviv9dl")
        (npm-tarball "@vue/devtools-api/-/devtools-api-6.6.4.tgz"
                     "1ixwrzwcs7qm45kn4ix98s4rhak3b5l7b0nwsgl1l51z30dfjnk3")
        (npm-tarball "@vue/devtools-core/-/devtools-core-7.7.9.tgz"
                     "0kn94aaz438qaizsa8kigkf4myrb2r3l49kmfs7r4ihc3hsfc14m")
        (npm-tarball "@vue/devtools-electron/-/devtools-electron-7.7.9.tgz"
                     "1sdiw6ghywh7acmhd0rll950wph6wb1sskmsk38amv69z9v28zvm")
        (npm-tarball "@vue/devtools-kit/-/devtools-kit-7.7.9.tgz"
                     "0j98za4is59knxqzg86qyy0z8bljjb3ci6q4bikcwmxakacabjx8")
        (npm-tarball "@vue/devtools-shared/-/devtools-shared-7.7.9.tgz"
                     "0n2164ik3bh5789rd71a1mkc595vhhpwx7is3dgbi7v8dqx0ldfq")
        (npm-tarball "@vue/devtools/-/devtools-7.7.9.tgz"
                     "0f098qvpx8klrv3y27426j67j5h91l2ha7wgcmj01jwnv364vmsj")
        (npm-tarball "@vue/language-core/-/language-core-3.3.6.tgz"
                     "0h4bxanjazasv3lq4ks7phxykqahvxmppzcl65giyxiqrgmc84pk")
        (npm-tarball "@vue/reactivity/-/reactivity-3.5.31.tgz"
                     "1jw2cwsdqvb4a2rvm7cz8pzfvwj02gqgqslgazmsy84cm5bqvilz")
        (npm-tarball "@vue/runtime-core/-/runtime-core-3.5.31.tgz"
                     "039aib4hgb0naggryzc6wg9g0007mnzg7ahwik6d4w5ydn9n0q73")
        (npm-tarball "@vue/runtime-dom/-/runtime-dom-3.5.31.tgz"
                     "0vwkfr1wf8i4q6f1k59bn5z12rng3caqnp32cckdqa68xmmb6k2z")
        (npm-tarball "@vue/server-renderer/-/server-renderer-3.5.31.tgz"
                     "0a3a5zhisszwdswyy4ldl64x6h1b9a6hlxmb9qiv82fyf5j2hg42")
        (npm-tarball "@vue/shared/-/shared-3.5.31.tgz"
                     "08c89n24iz72ylwf2rad3c0gidhabbhildnf39cy02yydykv8kmj")
        (npm-tarball "@vue/test-utils/-/test-utils-2.4.6.tgz"
                     "0s6a542j00s0i9nhb41qn2y020ri2lxgs6hazlj2qpyhfkmv8q1z")
        (npm-tarball "@xmldom/xmldom/-/xmldom-0.8.11.tgz"
                     "1a0sfr513r00d9i72n69cx84l9amv24888cl2kn8phxm0igzfn8j")
        (npm-tarball "abbrev/-/abbrev-2.0.0.tgz"
                     "0cajwx2cf5zmbklnp3qyrm7vivqy72an45sygmnqygl6nizdn0nr")
        (npm-tarball "abbrev/-/abbrev-3.0.1.tgz"
                     "1svqvmvg2dmyfqrzkr6vl2awd7cz252jnmy2k8sai9x9m7qrg8z7")
        (npm-tarball "abort-controller/-/abort-controller-3.0.0.tgz"
                     "0bxba0gy4rglq44q0dx5s2fzm8rw7vb11ihjgkjiisqhs3alkqnj")
        (npm-tarball "accepts/-/accepts-1.3.8.tgz"
                     "0xbds0r4v51s5lprkr6snag2xr5ssbavh9hmqygj4y427z59l65z")
        (npm-tarball "accepts/-/accepts-2.0.0.tgz"
                     "0hi56wcavwsv8s4mpvks7gywmjdiqcqa0a91vga8rpw8gmgr2g8p")
        (npm-tarball "accessibility-developer-tools/-/accessibility-developer-tools-2.12.0.tgz"
                     "0rk5ng26mx25d7y1m7z6j31awy3vvl3p0zg5gg9kaw6040w3jba1")
        (npm-tarball "acorn/-/acorn-8.16.0.tgz"
                     "07p1mf51jkvh7gspmpjan6m0pd2hrp1319grqw3rif02vh5cmbcb")
        (npm-tarball "adm-zip/-/adm-zip-0.5.16.tgz"
                     "08ygc9p5yq1fdgsg569sm30fagpw9m5l3nfyqvwjly2ggv81wmm6")
        (npm-tarball "agent-base/-/agent-base-7.1.4.tgz"
                     "0zmmkk3xhnkwb6djnvri7zyxllsdz5aa5w83x7afi959d0badm3x")
        (npm-tarball "ajv-formats/-/ajv-formats-3.0.1.tgz"
                     "1idca2hn65drqp1bc4v696bqvnv3x08nj1lrj791yf37sc7rimpl")
        (npm-tarball "ajv/-/ajv-8.18.0.tgz"
                     "1h4wiiwgxgx22ypaixp3z67ywmz86hxl26162p53gxg51crnwajj")
        (npm-tarball "ajv/-/ajv-8.20.0.tgz"
                     "1cz7yr42yf4kb0znhwyxslqrxqcr2j5z0538zdgcrf5vjflb7w5j")
        (npm-tarball "alien-signals/-/alien-signals-3.2.1.tgz"
                     "0c74c2bh1jvlhhh9isxjcq36xlc83dbd5rzacsrcaj17xz89yp4j")
        (npm-tarball "ansi-regex/-/ansi-regex-5.0.1.tgz"
                     "1ng0r2k4mcz7b2bfr6g1dschnxm0vifaslsvv2smv06smb6ss3hf")
        (npm-tarball "ansi-regex/-/ansi-regex-6.2.2.tgz"
                     "1mria9xwxjm9f6vq6bgyjfgpvnrjlaj936rr1k25v06qbn7vnip7")
        (npm-tarball "ansi-styles/-/ansi-styles-4.3.0.tgz"
                     "0zwqsx67hr7m4a8dpd0jzkp2rjm5v7938x4rhcqh7djsv139llrc")
        (npm-tarball "ansi-styles/-/ansi-styles-6.2.3.tgz"
                     "06wihdisbyp9ryhmf4ck0lrrbckp6lax1b0087ix99fp718wyfg9")
        (npm-tarball "app-builder-bin/-/app-builder-bin-5.0.0-alpha.12.tgz"
                     "00v4lh67msm6yrpgs9m68nqx5hgm9wqxp1r7vngpjvhnh2gkwyw2")
        (npm-tarball "app-builder-lib/-/app-builder-lib-26.14.0.tgz"
                     "0lfa2dk295l5ddl28f8fcgb3g2vgp9im9cyagnw0p5s321rjqnrf")
        (npm-tarball "archiver-utils/-/archiver-utils-5.0.2.tgz"
                     "0rvspdcyiy0d0lgjqmla98xy9w6akmwcjpb4cam6q8yyvasfl3in")
        (npm-tarball "archiver/-/archiver-7.0.1.tgz"
                     "0dc0djkq6y1vq8r7pij7ppy5lyq9xvq9h5y0kybg2l14krck26gb")
        (npm-tarball "argparse/-/argparse-2.0.1.tgz"
                     "133jjyhcr25rf4vy7bca7x06dfmsyy819s1kbbyfc5c2zi3ki417")
        (npm-tarball "asn1.js/-/asn1.js-4.10.1.tgz"
                     "1m8jrx7njdrygykajiz9gldixk8gp0bl0979l5i4zxsmmi5ixa5x")
        (npm-tarball "asn1js/-/asn1js-3.0.10.tgz"
                     "1qwpga15gmgn0pq56nxxgbfxn9lm054xyp0m4srjmbc0klqyxphh")
        (npm-tarball "assert/-/assert-2.1.0.tgz"
                     "0m50cs6mac188p07apqjpyc71vxwsq2pmal1wymkxh2bzmg7w0lh")
        (npm-tarball "assertion-error/-/assertion-error-2.0.1.tgz"
                     "0mhgq8w0jyw6x02gzy3p5zzfaglkly2lv38q4cqlz3mkr6rsbx3k")
        (npm-tarball "async-exit-hook/-/async-exit-hook-2.0.1.tgz"
                     "11d0c1kpakkyy25pn5g12g53qw7m7ywrwmq3hzyifi2pdfxnywni")
        (npm-tarball "async-lock/-/async-lock-1.4.1.tgz"
                     "0inx5jviyzvz9bixps6czbn41xc7kwhj61kjkv90qhq5y5198az2")
        (npm-tarball "async/-/async-3.2.6.tgz"
                     "0vqf4nhfjaqjkx5bvh3y2gz70c0ijjm6xkmkksiyxllcl3xmrd3b")
        (npm-tarball "asynckit/-/asynckit-0.4.0.tgz"
                     "1kvxnmjbjwqc8gvp4ms7d8w8x7y41rcizmz4898694h7ywq4y9cc")
        (npm-tarball "at-least-node/-/at-least-node-1.0.0.tgz"
                     "1yl3b109jav8v9hbbhqpdfaj31igi5mfjfgflx48rdnj7ml2gvbj")
        (npm-tarball "autoprefixer/-/autoprefixer-10.4.27.tgz"
                     "1p7m0m0kz6nkyd7g6iv9x8ms92vbvxw5a8nxnxmqzsmhyvq7ssya")
        (npm-tarball "available-typed-arrays/-/available-typed-arrays-1.0.7.tgz"
                     "0qvqrz4j0pkz90ld5bd4x2476pbmr40c9z6zs60kvppylc7hw54b")
        (npm-tarball "aws4/-/aws4-1.13.2.tgz"
                     "0qmd9r83904l4hgrrh4fm19swr99776m4c15ggpf116ihr0c3w4v")
        (npm-tarball "axios/-/axios-0.24.0.tgz"
                     "1gv98nzv4f86i4hrp27538bzk9j9j6q9jyrl2wdhpj61mlmmf33j")
        (npm-tarball "b4a/-/b4a-1.8.0.tgz"
                     "1wkxnmi94y59dg8jc7ja135vfcq8bqnn1cn0xx339rni51vvllha")
        (npm-tarball "balanced-match/-/balanced-match-1.0.2.tgz"
                     "1hdwrr7qqb37plj7962xbwjx1jvjz7ahl7iqrwh82yhcvnmzfm6q")
        (npm-tarball "balanced-match/-/balanced-match-4.0.4.tgz"
                     "05pva90symmxg31miw4msmd9g0q1aspf7764pcqybvi5j66m09ch")
        (npm-tarball "bare-events/-/bare-events-2.8.2.tgz"
                     "0khh128gsjrvs3w1ksy0kkh8nldjmd461dyw0swbbb7n9ssc2swg")
        (npm-tarball "bare-fs/-/bare-fs-4.5.6.tgz"
                     "1baism7nnxdvw8y674p03669kf103804gd9c2pv4gy7pph8sy4gm")
        (npm-tarball "bare-os/-/bare-os-3.8.0.tgz"
                     "00c21c9ciym72iljz1qwhbn1njsk1gl97c8601kabymsjbwrnvh4")
        (npm-tarball "bare-path/-/bare-path-3.0.0.tgz"
                     "19b8300fskcbx5c2kqk5dx027hjc0738d92jabsh41zsch2x7qwz")
        (npm-tarball "bare-stream/-/bare-stream-2.11.0.tgz"
                     "1yyg9gr27f1v9v1bxkrs6p772rgsz289a3zi55gpgg8k51120pfq")
        (npm-tarball "bare-url/-/bare-url-2.4.0.tgz"
                     "1mpdbkwx8nfqqzzympspmd8mhhwyhzw0avkqrz9s348n36zmkw2k")
        (npm-tarball "base64-js/-/base64-js-1.5.1.tgz"
                     "118a46skxnrgx5bdd68ny9xxjcvyb7b1clj2hf82d196nm2skdxi")
        (npm-tarball "base64id/-/base64id-2.0.0.tgz"
                     "0s49slcjsfw3f24znc5a33xa7mywqzjcf4ajqjc3cs77k1jm2d95")
        (npm-tarball "baseline-browser-mapping/-/baseline-browser-mapping-2.10.10.tgz"
                     "15vcq7zxh2zy385pg09lpaip1fyqkxn4kydkjixi7k6qrznmmd8g")
        (npm-tarball "big-integer/-/big-integer-1.6.52.tgz"
                     "11qzzsx416yxni5bqn0828118n9rnsdd8wxqhfh77s5ihmqcch2l")
        (npm-tarball "binary/-/binary-0.3.0.tgz"
                     "02b9idb0bfzzhdncf0a23s41k9570lyvx89wds3pba5j1yscj2wl")
        (npm-tarball "birpc/-/birpc-2.9.0.tgz"
                     "1a2qryrnws0mfj96ammr0ax61m08sr5gjbm1534x1cz63jxckf8c")
        (npm-tarball "bl/-/bl-4.1.0.tgz"
                     "1jx7lm4mr80nzdw0k873llpl1x6i1n0m422v1scwla8qml4vkpl3")
        (npm-tarball "bluebird/-/bluebird-3.4.7.tgz"
                     "1pg2s95l855gcpfbip4zbpznah9li7kcmzd7n8v460i85p1ql8p9")
        (npm-tarball "bluebird/-/bluebird-3.7.2.tgz"
                     "1p3dh022lvsrmsfyz37nr2x96g85y3356l4pgqkn32gm8hm0p2y6")
        (npm-tarball "bn.js/-/bn.js-4.12.3.tgz"
                     "1iny8ivyxzg733zs8wirz4j8jb0fk2x0y63ydprnp3h37dd5328q")
        (npm-tarball "bn.js/-/bn.js-5.2.3.tgz"
                     "0jn80ar6m18mswiaa6kbgxiqaaj2wsf2kvxgsk7jvammvx5i4ajz")
        (npm-tarball "body-parser/-/body-parser-2.2.2.tgz"
                     "02x3fgd42cf09bdadwb84k7jb31b0nq0m8kkb70aqpc0gqs9g3f2")
        (npm-tarball "boolean/-/boolean-3.2.0.tgz"
                     "0sm78kkkfavw87jhh0y3ahwzghxkjmf01jlj1syikljpkr93yvpm")
        (npm-tarball "brace-expansion/-/brace-expansion-1.1.12.tgz"
                     "1j6a7gsnsgp2baf9nk8y37cggnfchrnjb5m048ynam5y82lbxllm")
        (npm-tarball "brace-expansion/-/brace-expansion-2.0.2.tgz"
                     "0xdfhz9pqmzwl71gmnyhaj04llw9q159bdsq98fap0zw827ccqz3")
        (npm-tarball "brace-expansion/-/brace-expansion-5.0.5.tgz"
                     "0c8gk753jk8q649351fwz9sgvpf8yqddf7ykpfrw419gj2nc06g9")
        (npm-tarball "brace-expansion/-/brace-expansion-5.0.6.tgz"
                     "000692q8z98k7l1xj8na27bm1pv9gvvsjpwi5crss9kcbgswg9gw")
        (npm-tarball "brorand/-/brorand-1.1.0.tgz"
                     "098jln7s6cqp4xrjfbikxr91lkvnvxp928nrjr56kx8jvdb0dpba")
        (npm-tarball "browser-or-node/-/browser-or-node-3.0.0.tgz"
                     "1fhvwvdxzzqaqd3s0qgl17xc15iq7sv2xrppwhm73bp5wiv2s6nd")
        (npm-tarball "browser-resolve/-/browser-resolve-2.0.0.tgz"
                     "0ink8fjqqk3ichbfxmn2gdcykikcpf8ws1anma1zpsrgn5ccgaj2")
        (npm-tarball "browserify-aes/-/browserify-aes-1.2.0.tgz"
                     "0s71laf6qx5n2ai2h92qn3f0l7831lvxlg4kc4pix1mdr42vlr4v")
        (npm-tarball "browserify-cipher/-/browserify-cipher-1.0.1.tgz"
                     "1r06d9y349w34dimszb0bncd7kpw3xcky8m6d5dsx6g959f1aa1d")
        (npm-tarball "browserify-des/-/browserify-des-1.0.2.tgz"
                     "08clvbmmpx5x1dppmygb6fnm9zzdg3czraqa1wximgdbb1m3nl5p")
        (npm-tarball "browserify-rsa/-/browserify-rsa-4.1.1.tgz"
                     "0ihdxdmf9q14104gsn9j0fmddfdwzhx4m09fw894f4ymzs3jd3m0")
        (npm-tarball "browserify-sign/-/browserify-sign-4.2.5.tgz"
                     "1q2sziihl4sk09s3245ij7j6k9c4mf2f1narshk5mkqmikxpa65i")
        (npm-tarball "browserify-zlib/-/browserify-zlib-0.2.0.tgz"
                     "0vm3pnw1nnj98849ai2xxrrm1v1alb7kiyh076l0n5hyi3rx1i7n")
        (npm-tarball "browserslist/-/browserslist-4.28.1.tgz"
                     "1m8x8njj6hq6sdicg4qv4mivlian8yhac7wgk8pcsn2kcsg9ng1f")
        (npm-tarball "buffer-crc32/-/buffer-crc32-0.2.13.tgz"
                     "0vf6adpqimbz921y729mf91pvghihj44js2ck5ci44zh4x21bl97")
        (npm-tarball "buffer-crc32/-/buffer-crc32-1.0.0.tgz"
                     "1vl351xp86pib9la273sskivr86331yag82xm0p3k7abr6vsmvdv")
        (npm-tarball "buffer-from/-/buffer-from-1.1.2.tgz"
                     "0hz3cbll0m805g22c5pnwdgpi1xavmrp5q1734x4d3yakvah6aww")
        (npm-tarball "buffer-indexof-polyfill/-/buffer-indexof-polyfill-1.0.2.tgz"
                     "1j4x63gh145vlv4cfr7xfflrpf9g6gqc8688fmi5yg6mb08s696g")
        (npm-tarball "buffer-xor/-/buffer-xor-1.0.3.tgz"
                     "0jjgqva9x5i606fy8hr91zsnxbrybx18k152kl7njqhf81lb1vvb")
        (npm-tarball "buffer/-/buffer-5.7.1.tgz"
                     "1g60az00dzb1grcszyg12gyrl9jr9bwvrk2y9xjdwym3nxasrgwq")
        (npm-tarball "buffer/-/buffer-6.0.3.tgz"
                     "1xaim9bjs0l0any341dijprl7x576k6sgbm9qnrgdz2a494nynsm")
        (npm-tarball "buffers/-/buffers-0.1.1.tgz"
                     "0vgb3m22f4vlnwh35ijs733cxfvmfzcbb1wn5lc0aw261v34kppq")
        (npm-tarball "builder-util-runtime/-/builder-util-runtime-9.6.3.tgz"
                     "0si29dzglfrgfcg5ypy8ky8m74rmw9xqp0yv5jlhgz9yc50hqj4p")
        (npm-tarball "builder-util/-/builder-util-26.14.0.tgz"
                     "0dr5kaqi1lrfg51c5wrg2ybf53zb7pz80vn9dj0a4h325dja49dz")
        (npm-tarball "builtin-status-codes/-/builtin-status-codes-3.0.0.tgz"
                     "1f4xnx0pav796sdr414cx51j8knpymxkxby4jasbzz2rx2b1hvii")
        (npm-tarball "bulma-checkradio/-/bulma-checkradio-1.1.1.tgz"
                     "0yfca4ky3lrhrw790snwaf8srpb31rywvw1xzc2dnwlyd87cj9h5")
        (npm-tarball "bulma-divider/-/bulma-divider-0.2.0.tgz"
                     "0k0cl337y6c9dccqnr5fnni0zcb9nzp870rjv7b96d0zp9sa8xgq")
        (npm-tarball "bulma-slider/-/bulma-slider-2.0.4.tgz"
                     "191gklmmfrbb1hv45wyq47q62mrrjshmzfl1yifkg0628r5cj6jp")
        (npm-tarball "bulma-steps/-/bulma-steps-2.2.1.tgz"
                     "1gdyslv62llhbjn76imn11lsfqkpflsp6h6q9q7ldxs0jf4hr31f")
        (npm-tarball "bulma-switch/-/bulma-switch-2.0.4.tgz"
                     "0fw8kxdmqg44k8v8zkmylznvm1m4lswlvj9cll1x4lqalmj0lj4d")
        (npm-tarball "bulma/-/bulma-0.9.4.tgz"
                     "158yvn69ah7zya4fpzjn0j3x7lqgfydgs23r129hryqhamhsijgn")
        (npm-tarball "bundle-name/-/bundle-name-4.1.0.tgz"
                     "0489x4n9f6z8v4qpycgakqp30j58xsgi69lrl96bw7698119vr1m")
        (npm-tarball "bytes/-/bytes-3.1.2.tgz"
                     "10f5wgg4izi14lc425v7ljr1ayk28ycdjckfxpm4bnj0bankfpl3")
        (npm-tarball "bytestreamjs/-/bytestreamjs-2.0.1.tgz"
                     "1ypp9dvyz3cdylynsgm21px1w5qs78a3z7qa8lhjh8g4icyaz9p1")
        (npm-tarball "cac/-/cac-6.7.14.tgz"
                     "1gjj94xq29h2820v7fc9y9x4xmwj2vgynkhp5vj1xsq3m9hsbnyn")
        (npm-tarball "cacache/-/cacache-19.0.1.tgz"
                     "1ky833lmakv85nddwl128nhc5ywnvibpvf7207kj0nifc9jh42qb")
        (npm-tarball "cacheable-lookup/-/cacheable-lookup-5.0.4.tgz"
                     "1346y7d3p5b4jmfc39k8csxks229nkmdmanmmzabqnya0vzan694")
        (npm-tarball "cacheable-request/-/cacheable-request-7.0.4.tgz"
                     "13l93qyb31yma8dg719xfk6rl8wjwpchkz2wvng95y4gap5nfwmv")
        (npm-tarball "call-bind-apply-helpers/-/call-bind-apply-helpers-1.0.2.tgz"
                     "0b3xqfkmcxhancq8h4cd3282ryg9h5rnf2h2530zbvdbvgwrygh7")
        (npm-tarball "call-bind/-/call-bind-1.0.8.tgz"
                     "08q5gghb493kzi1hx8wzgrwlrgsw2ks1s5p4g9915h00rvrvvqih")
        (npm-tarball "call-bound/-/call-bound-1.0.4.tgz"
                     "0cmxdglg3lrrz7apqgvqbkd57jicr98fxwhi92rvkwgd5x4ny21j")
        (npm-tarball "camel-case/-/camel-case-4.1.2.tgz"
                     "1h86b9r585cxq433cy74skn6rglg94xf56d3383w878xarw9f358")
        (npm-tarball "caniuse-lite/-/caniuse-lite-1.0.30001781.tgz"
                     "1awd73l2m1d8bhdl5hp3rlvk4k9rqsxyk9yv6girzm4sf7y3ib8r")
        (npm-tarball "chai/-/chai-5.3.3.tgz"
                     "03zhak2ni205zkzry0f8wq1c8bam94078zryi1z402m6kk3v0hmq")
        (npm-tarball "chainsaw/-/chainsaw-0.1.0.tgz"
                     "1yvcjymlp04v3hi25b131zilyw7004nq4sgzgbh4l5yil5m6ln01")
        (npm-tarball "chalk/-/chalk-4.1.2.tgz"
                     "02prgl8d52k2vgxnssx06ha2sjm2vp6v6s6kqgkar1ryllx68k78")
        (npm-tarball "chardet/-/chardet-2.1.1.tgz"
                     "02nmh73jvf04qx224w8lk5y71s0jpczy77r612vsdad9vc3vr2ly")
        (npm-tarball "check-error/-/check-error-2.1.3.tgz"
                     "1w3dklvvas01lrcyxmpj2jxfybgyhrkbqg3qc8d5gbs9whw9c94f")
        (npm-tarball "chokidar/-/chokidar-4.0.3.tgz"
                     "12c3hr28bai0n50vxm73fc365i0l900jfwxylwrwvhhlsflrv8k1")
        (npm-tarball "chokidar/-/chokidar-5.0.0.tgz"
                     "1qzmyw8jg7gr3zj0f593phii9p4yqiy58g5b6g3q5r3ysnkpxl25")
        (npm-tarball "chownr/-/chownr-2.0.0.tgz"
                     "177wsdfmn1d2f12wy8m875b5y9a74ibfdh33jarlv3a0zrbmvqlv")
        (npm-tarball "chownr/-/chownr-3.0.0.tgz"
                     "0q0k3cr7h7bmjxc85a2hji3ym47hgmgnbpl9v992451hlvdga92c")
        (npm-tarball "chromium-pickle-js/-/chromium-pickle-js-0.2.0.tgz"
                     "0vp1cc1zzwvs8pjyf0mpyiiriggngd87sc7n49gkxl158brcs9xj")
        (npm-tarball "ci-info/-/ci-info-4.3.1.tgz"
                     "1zvrnjficpf4ra6509cf8l65v6xbv34805i2mk12czlh2hpmbyap")
        (npm-tarball "ci-info/-/ci-info-4.4.0.tgz"
                     "07srv966n8h2lryysjmr2sig8gfwxnan27mgr17kbw7j99093p4h")
        (npm-tarball "cipher-base/-/cipher-base-1.0.7.tgz"
                     "0jq4fy2r54pb26mj0pjgs1hryys264cq4916lkb6rjfci9l24amd")
        (npm-tarball "clean-css/-/clean-css-5.3.3.tgz"
                     "183rvjdldqbjm7hl2qqbhjg896jh0qdb6ykpa313z0pwr1vcafpz")
        (npm-tarball "cli-cursor/-/cli-cursor-3.1.0.tgz"
                     "0k4qgv5xd9m6rh4aj20gzgdzf1zb647ddxpky3db911vqm6hxkxm")
        (npm-tarball "cli-spinners/-/cli-spinners-2.9.2.tgz"
                     "135l0bd57jgzjnkf3frpj32ya2rzynr95fz9qsbi4yxwvr74rhj6")
        (npm-tarball "cli-width/-/cli-width-4.1.0.tgz"
                     "1yvzami87nskrakdml9biflyy1hkf3njswg0wd89j5hb1r91ys0p")
        (npm-tarball "cliui/-/cliui-8.0.1.tgz"
                     "13cc8rvmzcvvlvf2prwxj1zjyxhybsznl1nirnlrwd4abvid3yny")
        (npm-tarball "cliui/-/cliui-9.0.1.tgz"
                     "1kbib56gwn6b1s5sbwslg8nixlhminmi8ig2d8zfnl90d14jbmr6")
        (npm-tarball "clone-deep/-/clone-deep-4.0.1.tgz"
                     "0k1szrzsy3d3k3akxy4r6mg1kzj74h81097598lwndw65pvr92pd")
        (npm-tarball "clone-response/-/clone-response-1.0.3.tgz"
                     "0rp9mi1n1dfya1ibq3r17z6g9iqx3q7nz9gphslkwj6vpf14kf1i")
        (npm-tarball "clone/-/clone-1.0.4.tgz"
                     "08w0b18a2bjh19fm2jwxyl7irxk8g4m0bm3ah99x7ph04iaxb4rk")
        (npm-tarball "clone/-/clone-2.1.2.tgz"
                     "0gg90kb5jpm6bcmqfhvmfbx8dralysv5v9ph8b38a89ni9hkmxkx")
        (npm-tarball "collection-utils/-/collection-utils-1.0.1.tgz"
                     "0ljikdrf24hqhxcbj0hgwbr15jwrb4p37f6i1bscnqq6b6xvmizz")
        (npm-tarball "color-convert/-/color-convert-2.0.1.tgz"
                     "1qbw9rwfzcp7y0cpa8gmwlj7ccycf9pwn15zvf2s06f070ss83wj")
        (npm-tarball "color-name/-/color-name-1.1.4.tgz"
                     "020p7x7k8rlph38lhsqpqvkx0b70lzlmk6mgal9r9sz8c527qysh")
        (npm-tarball "colorjs.io/-/colorjs.io-0.5.2.tgz"
                     "0152r56iq5n157ip0d1ja4cz9jwmqhs98b4xhvl4hipx9rffmws9")
        (npm-tarball "combined-stream/-/combined-stream-1.0.8.tgz"
                     "04hm5rrkwda2qgy1afwhrz42asmflw5hxkbpxddn741ywnmmmgmn")
        (npm-tarball "commander/-/commander-10.0.1.tgz"
                     "1lpp3xd6z4mk6nva84c820fvr08gs0i514c7i9wsnf4brx14c7za")
        (npm-tarball "commander/-/commander-13.1.0.tgz"
                     "0al26hpacjd8ik4wr63x95wqh92f0sgpmkzyhrnnsv9khni3nw6m")
        (npm-tarball "commander/-/commander-2.20.3.tgz"
                     "0m9bcmcwgn2zj6hdqydnyx6d1c5y014ysazyqd6qva8pw0yr00iw")
        (npm-tarball "commander/-/commander-5.1.0.tgz"
                     "0r25hfs7j28xxyvb8abmizlpw72xb57k2nz6yadibr2likfcdry2")
        (npm-tarball "commander/-/commander-9.5.0.tgz"
                     "0lig2h2wyydirfngs273jzj816nbiqxvd95109hc4f6vd2zlhjdn")
        (npm-tarball "compare-version/-/compare-version-0.1.2.tgz"
                     "0g0d9fhy6p31ddqinrrrmn2axvsvpfab0i004g46yfv7w8pyd4b1")
        (npm-tarball "compress-commons/-/compress-commons-6.0.2.tgz"
                     "0x3b0frzh4cgzl802ii7i2b2dlsl509lj95dnzyn1gydc3hv5bjg")
        (npm-tarball "compressible/-/compressible-2.0.18.tgz"
                     "1mjr4010mlv5qim0n2by0gz5wiayscy7anaf712q19i4ha79syx5")
        (npm-tarball "compression/-/compression-1.8.1.tgz"
                     "1mfmkma8n5qjqk46w1magrimqz379iz58zv8h6p2yj2kbga785l7")
        (npm-tarball "concat-map/-/concat-map-0.0.1.tgz"
                     "0qa2zqn9rrr2fqdki44s4s2dk2d8307i4556kv25h06g43b2v41m")
        (npm-tarball "confbox/-/confbox-0.1.8.tgz"
                     "10jcpgfsck2zmkhf2wrs1b3p7gbiga8hn7kj1v3iw44368jlwwjw")
        (npm-tarball "confbox/-/confbox-0.2.4.tgz"
                     "0gp3804p7l649p2falrm8visyvdgas7p3qwkdj9vqzmhhjac1a3f")
        (npm-tarball "config-chain/-/config-chain-1.1.13.tgz"
                     "0rhcwq8fbp2hlg5yhjaq8w1910pmbl80wkjwlv39axxfk1fmaa1b")
        (npm-tarball "console-browserify/-/console-browserify-1.2.0.tgz"
                     "0h0h5i9rvfswmy5qm9kyhqsc93hc6s08r1i0rxs930nmfdzqcv9f")
        (npm-tarball "constants-browserify/-/constants-browserify-1.0.0.tgz"
                     "0n8zjdpk4yrv2h86rxipsdmk5mq2c6gb99iwgr4ykp4xc3yhg4za")
        (npm-tarball "content-disposition/-/content-disposition-1.0.1.tgz"
                     "069ag0zxqjzkdwgpmk9xrhnz9hbrngy5annr13z7dhrnr7pyklnx")
        (npm-tarball "content-type/-/content-type-1.0.5.tgz"
                     "1j0jpnlxjrdpbnq7s1h1xga2n8562j5g6612f7fl40jz82cd0cdc")
        (npm-tarball "convert-source-map/-/convert-source-map-2.0.0.tgz"
                     "160qzrwfhj8xkc2ya476hp7sahaj5gnzv4hi6xl9zq74qwz2bxqp")
        (npm-tarball "cookie-es/-/cookie-es-1.2.2.tgz"
                     "0mgw9iw1g7ky0sa1d4jxmc54mimarigsd9ipwyj3q56rgm4brj69")
        (npm-tarball "cookie-signature/-/cookie-signature-1.2.2.tgz"
                     "1lsk6l4501i1sil49gdwdkaj0nzr5asm5ybx1ppn17i93jpvlasd")
        (npm-tarball "cookie/-/cookie-0.7.2.tgz"
                     "084ymsdgqj3jc00gh39cbfbmh1vval1wy2ifd88hlqqw4pw61cbn")
        (npm-tarball "copy-anything/-/copy-anything-4.0.5.tgz"
                     "0qjqi3dzs8bdyp0i0xn240sipc5izb6nl3yfz8qzm9hvly21m7rf")
        (npm-tarball "core-js/-/core-js-3.49.0.tgz"
                     "1nlzbcakalzgpzywf895f3793wrc4arrh9cic54ffcpzdhg1vmkw")
        (npm-tarball "core-util-is/-/core-util-is-1.0.3.tgz"
                     "032dwykfbxff1q7s0kgqdkwwzmm25mlrlfqijzibbwrc3z3zsc24")
        (npm-tarball "cors/-/cors-2.8.6.tgz"
                     "1zy1q5b9ny116yfmsr8vr1c9srklrns558iq28780h3i74j2291j")
        (npm-tarball "crc-32/-/crc-32-1.2.2.tgz"
                     "0my64hxqn3hdkzilds3mycjx8amdf57kzfhsw34iff6kqdryaywr")
        (npm-tarball "crc32-stream/-/crc32-stream-6.0.0.tgz"
                     "1hbgkiwsdgd0is8if3yr68lz4r6swjrbjgxjjqh0fgylbsisqwbm")
        (npm-tarball "create-ecdh/-/create-ecdh-4.0.4.tgz"
                     "1q9wf40kj32qwi9wygxr0l0hvl981k6wksn5hl3jhkyzcb8840cr")
        (npm-tarball "create-hash/-/create-hash-1.2.0.tgz"
                     "1bab07i2b8j98wacjdzknsypv9dcial4j3sky7qwqcnr1d4pjh7y")
        (npm-tarball "create-hmac/-/create-hmac-1.1.7.tgz"
                     "19vs6cvgdx0pyjjx955szg2fza80pbm621f3rkc6cidqc3wdlxzx")
        (npm-tarball "create-require/-/create-require-1.1.1.tgz"
                     "0xd2xpbi272wipkg8d40pgihvq94z017p03cghf5rsz2d30k7dc2")
        (npm-tarball "cross-dirname/-/cross-dirname-0.1.0.tgz"
                     "06apqdc164i47qy6mmni9jr2za676hx9x2bzxfymwdvsl6c0y3ya")
        (npm-tarball "cross-fetch/-/cross-fetch-4.1.0.tgz"
                     "1n8sal6dnngrv94yn7ip3214i4rngx5dyks9fj97vbp2kycjyphc")
        (npm-tarball "cross-spawn/-/cross-spawn-7.0.6.tgz"
                     "1siqxlydjwpihy7klgd15cah56vsmxrdm3q90gndyfj1vh63530q")
        (npm-tarball "crossws/-/crossws-0.3.5.tgz"
                     "0iikivfcm8yy8byikr4z44dhk97xkgg0hjk0awvpwhmb9awi377v")
        (npm-tarball "crypto-browserify/-/crypto-browserify-3.12.1.tgz"
                     "11gyq6vrnbcfr61mmragb2a0za5wfqz7ypmyr9mmkqcja6md6rzg")
        (npm-tarball "csstype/-/csstype-3.2.3.tgz"
                     "18r7fhq1k5apllflcqljwmkh8b0n649c28nbzrl7agy7w671yl7k")
        (npm-tarball "de-indent/-/de-indent-1.0.2.tgz"
                     "0zfmdhk0pbz1qm9ic2sp968nbx69xc3yz3dfkl4iijc0i46w0iyk")
        (npm-tarball "debug/-/debug-2.6.9.tgz"
                     "160wvc74r8aypds7pym3hq4qpa786hpk4vif58ggiwcqcv34ibil")
        (npm-tarball "debug/-/debug-4.4.3.tgz"
                     "19z48fpic8jbb2833gh3bviylzp9512i2dsqhxd91s3fjjfarhc9")
        (npm-tarball "decompress-response/-/decompress-response-6.0.0.tgz"
                     "0krv58fihkajrskzakm1i69kklv0ycabrjmlgk2a9kkv0idlqznm")
        (npm-tarball "deep-eql/-/deep-eql-5.0.2.tgz"
                     "0dig56m63wh9c73c3xp3spb1gw2awym0sal5b19w20b2dbikf627")
        (npm-tarball "deep-equal/-/deep-equal-1.1.2.tgz"
                     "04hwz5rl9y339g9y0rwga9ncz8y4dpwzhb5cvm7kdiqwzhwn00pw")
        (npm-tarball "default-browser-id/-/default-browser-id-5.0.1.tgz"
                     "0ablblhrzy81aixklbvdvq5fzdybh33q1086vkk0sq8bv7hgp51w")
        (npm-tarball "default-browser/-/default-browser-5.5.0.tgz"
                     "1dqjhvmgb0n9ni1lcg22af9l4yi0ydi5ahr5f5yssjjb9zl5rqzg")
        (npm-tarball "defaults/-/defaults-1.0.4.tgz"
                     "07l9fhw54y31467ijn780byl3ck72x32wmk2q2pvk6rpv28f1px6")
        (npm-tarball "defer-to-connect/-/defer-to-connect-2.0.1.tgz"
                     "0cnlka4hxw7mrl8rphpslcbxb5pc8d7w6jwv1fhpmj89nx6hfny3")
        (npm-tarball "define-data-property/-/define-data-property-1.1.4.tgz"
                     "1lp423qridddixk0b6sgkccdf770knbaha1wcal4qdpi7pbllc0n")
        (npm-tarball "define-lazy-prop/-/define-lazy-prop-3.0.0.tgz"
                     "1da99k4vnnn9bxpgjniai8248bcf4w9cwyn7p3wlzii9l9kzxsdv")
        (npm-tarball "define-properties/-/define-properties-1.2.1.tgz"
                     "1x20dff3wz5pp7ciyxbyhglgxvggwsavd56l7ivrvvmd9y0f7rsx")
        (npm-tarball "defu/-/defu-6.1.4.tgz"
                     "14mjwyg6h46cxibszhcixjlklvjbghzik49m96pw9q3rq0qh92ha")
        (npm-tarball "delayed-stream/-/delayed-stream-1.0.0.tgz"
                     "1lr98585rayrc5xfj599hg6mxqvks38diir74ivivyvx47jgqf5c")
        (npm-tarball "depd/-/depd-2.0.0.tgz"
                     "19yl2piwl0ci2lvn5j5sk0z4nbldj6apsrqds3ql2d09aqh8m998")
        (npm-tarball "des.js/-/des.js-1.1.0.tgz"
                     "17gg4jlp9w2rkxizfn80zhnigs8pq862jmv21avrpjiq9qlvh1ls")
        (npm-tarball "destr/-/destr-2.0.5.tgz"
                     "0r0as8xq55pb5l2dwj4gj1cmmj27rmjkhr18ayb6a7chgps15rvl")
        (npm-tarball "detect-libc/-/detect-libc-2.1.2.tgz"
                     "09wlldyqvhf2w7q4xcch4xh6pvldy7c2vbx83m48dzvcq07yq397")
        (npm-tarball "detect-node/-/detect-node-2.1.0.tgz"
                     "1qw23a1wlk4fpk4j0nc74hgwwgafd25vbrq1l7ppmpsnd3p0aq03")
        (npm-tarball "devtron/-/devtron-1.4.0.tgz"
                     "0fqwrv4hjg9yvc2sz6kxprpjd6p5sr67ql391kw5413sr8pbm434")
        (npm-tarball "dexie/-/dexie-3.2.7.tgz"
                     "16b6slkzzi43sfgvzv1wlmkwk28pnjmplkwmlvq9wkndsm2bhlyn")
        (npm-tarball "diff/-/diff-5.2.2.tgz"
                     "0r0skyj6qim9a8gf52x8y394xph6ld6k91j7pgzkciw1v0p1diyi")
        (npm-tarball "diffie-hellman/-/diffie-hellman-5.0.3.tgz"
                     "0fp5zgad59kxl9pm0icf4dfm4cngzsplyk5f1mms2lskybh9m037")
        (npm-tarball "dir-compare/-/dir-compare-4.2.0.tgz"
                     "1jyvlbmsdzxgd4zfbcalfx3l0isvi9119zkhs7ki4n4k5xnkamxq")
        (npm-tarball "dmg-builder/-/dmg-builder-26.14.0.tgz"
                     "1bj5x1rfcmdyg4j4r4n16w3vmgrqkcidkwlndhr6nij4mx93ajpz")
        (npm-tarball "domain-browser/-/domain-browser-4.22.0.tgz"
                     "17m159zf0idgh99rsvfb9qp8y8p63nh2jsm2im3r82j57591zmxf")
        (npm-tarball "dot-case/-/dot-case-3.0.4.tgz"
                     "1sysb2mhxxwh1qb53p1q3gk262m1qj1zp2mjx9cmpl09plfrnyc2")
        (npm-tarball "dot-prop/-/dot-prop-10.1.0.tgz"
                     "1pdjma574wrljcxz33ryn7aw7p0rsbf6cgyp19f9bycd1a9dr3di")
        (npm-tarball "dot-prop/-/dot-prop-5.3.0.tgz"
                     "0p76z3nwlibbcrl5md6ik6211nv0b6hf26phmqsdgv9lrvbj0gmg")
        (npm-tarball "dotenv-expand/-/dotenv-expand-11.0.7.tgz"
                     "0rfjasb6v7cg5wm0yk1my1rb2n3kxn2bki2njsiys6qqwrnqj758")
        (npm-tarball "dotenv-expand/-/dotenv-expand-12.0.3.tgz"
                     "0s1hbjwakbbw0wi6xqahqsssxhw3r2abqnwjpm9vg0cafjq207dx")
        (npm-tarball "dotenv/-/dotenv-16.6.1.tgz"
                     "10ksnkzns9j73a84zab3hhkkrsbf91r0la0dqkikc9qqybbwb5bl")
        (npm-tarball "dotenv/-/dotenv-17.3.1.tgz"
                     "0fsh9gnnhqanzyhp4h8r9cc667k567k44k8y951cmzks84jnclly")
        (npm-tarball "dunder-proto/-/dunder-proto-1.0.1.tgz"
                     "1nyg4r9qjc33kmgixdi5xpb0qsjivy2dcn8wjbwhvhc2ihi444zd")
        (npm-tarball "duplexer2/-/duplexer2-0.1.4.tgz"
                     "0scvc51gwkvw22kfacgvnz4ppbwcdgql2x2idg5009icx2z613jz")
        (npm-tarball "eastasianwidth/-/eastasianwidth-0.2.0.tgz"
                     "09scd6l5al78hmhgims39mmrldjlwnjd2yny1679y7x7plms3kzc")
        (npm-tarball "editorconfig/-/editorconfig-1.0.7.tgz"
                     "0ggcsvxdcx4nwjnpvb9j120j473jahnawj179i53idqzkh7q772s")
        (npm-tarball "ee-first/-/ee-first-1.1.1.tgz"
                     "175r500n567a04qmswzw5hkgdnika3dvn63n284jlar2gvmyhj2i")
        (npm-tarball "ejs/-/ejs-3.1.10.tgz"
                     "15dvwk4zv8x9wq34wzzm0g01wirry1c9xbcwpaggffdlf04xc2lr")
        (npm-tarball "electron-builder-squirrel-windows/-/electron-builder-squirrel-windows-26.14.0.tgz"
                     "1gqznwba2xdr47y8lb8knk4cxqclaz3pqlyl7hcx08sxx33hbwdi")
        (npm-tarball "electron-builder/-/electron-builder-26.14.0.tgz"
                     "091fy0iany2wxg2g2ldcwfkhnwsp374mssyg4kpsl8wkigs55f4p")
        (npm-tarball "electron-debug/-/electron-debug-3.2.0.tgz"
                     "006rzk40yq8ass01131gyfqm5c938iy270j9m6yvq13gbv5z57v4")
        (npm-tarball "electron-devtools-installer/-/electron-devtools-installer-3.2.1.tgz"
                     "08pq8gdsy83gicdhh4jhxir9inhixf8r0kdaw9s0jcsh670f7bf0")
        (npm-tarball "electron-is-accelerator/-/electron-is-accelerator-0.1.2.tgz"
                     "0ywar35pnm4f1d5svxdhm2415h1dhrkg4hdp3sabd52dzj1905nx")
        (npm-tarball "electron-is-dev/-/electron-is-dev-1.2.0.tgz"
                     "0bf72nvhakxykd26wqdd9ggqgm3w5g2zac8ky2lkb5jhxmb46h50")
        (npm-tarball "electron-localshortcut/-/electron-localshortcut-3.2.1.tgz"
                     "0xvhdrg02rf98s724zg7f6gds3a9i202vf4294cg6mzp1qi7h4hf")
        (npm-tarball "electron-publish/-/electron-publish-26.14.0.tgz"
                     "1q6aw2l3nw824cdjfncp63z5hm02i6l4hp0c8f7rqd32d20qrh6l")
        (npm-tarball "electron-to-chromium/-/electron-to-chromium-1.5.325.tgz"
                     "0dq4628hkn7zf90jyc46n5ds2w3m7zh8mng74ahrj02y1hlg0n6d")
        (npm-tarball "electron-updater/-/electron-updater-6.8.8.tgz"
                     "0nh4wfjxn6m6b79lamffcs194fsl00mhyim92n2pmfzsa492s95z")
        (npm-tarball "electron-winstaller/-/electron-winstaller-5.4.0.tgz"
                     "1cddh2ab2gpy1zi8zw7afrg2ggg4addypg5lhgkwqji24srrgbs7")
        (npm-tarball "electron/-/electron-33.4.11.tgz"
                     "0dia7ca7pk699m0qpbyqid6j5kjykiyp1y0fja1bgmq6d87vhd1n")
        (npm-tarball "electron/-/electron-38.8.6.tgz"
                     "0k497mb91nx4v4d7316bnh58m665plx6laxyzy7wzd1n52952f0w")
        (npm-tarball "elementtree/-/elementtree-0.1.7.tgz"
                     "06iwxk4nlr0jyn7p7g53j64hd38rdz6iz00pz7andk7rx553ldzk")
        (npm-tarball "elliptic/-/elliptic-6.6.1.tgz"
                     "1h19l99737p32p2ibzi390m85a79kcqing1970bzqapnjjv34ldf")
        (npm-tarball "emoji-regex/-/emoji-regex-10.6.0.tgz"
                     "10grry6fs4mgixgbb778469vi523cli0vvp0xj10iww60m6fah4z")
        (npm-tarball "emoji-regex/-/emoji-regex-8.0.0.tgz"
                     "01xi3ikahnlj77h2gqs3jb7kmnxn1nsb9dmnpvpqw288zgxxkk5m")
        (npm-tarball "emoji-regex/-/emoji-regex-9.2.2.tgz"
                     "0zmfcyy2d2ki43dakckq4h649q8w4jiyl0b5lc6bsfmjh3x8viqx")
        (npm-tarball "encodeurl/-/encodeurl-2.0.0.tgz"
                     "0agvpr5psd2nymhp51l5502fzifkshxxlnixl7kzkf2ii25l2blv")
        (npm-tarball "encoding/-/encoding-0.1.13.tgz"
                     "116gipr1y0hc9zvflsvd39psbbf2j62zvpnw099pqf7fl0nb5xbc")
        (npm-tarball "end-of-stream/-/end-of-stream-1.4.5.tgz"
                     "02d3hkin7l3ac84mn3icdm1dp30khbx9v5x4ndvjnr6w61h2m73d")
        (npm-tarball "engine.io-client/-/engine.io-client-6.6.4.tgz"
                     "0ki2nanifd1167j55sy69ws55c44ibb8vyibjg982a7vm1ag4ny5")
        (npm-tarball "engine.io-parser/-/engine.io-parser-5.2.3.tgz"
                     "0rjmn5wlnzabw9r3qdpn0h3i1k25z310dq1x8z0bc4gx846vj07w")
        (npm-tarball "engine.io/-/engine.io-6.6.6.tgz"
                     "0linxc5all23938fykygpddxb6znlpmf3rlhviyhjfh9rhysmm54")
        (npm-tarball "entities/-/entities-4.5.0.tgz"
                     "0cm6cgsfcsgk3djx00wiv3vfrrq9kwlvkny83yxna2qs6pvn033b")
        (npm-tarball "entities/-/entities-6.0.1.tgz"
                     "17a7nnk35mxs5w3c7qdny025m8nmrq0616p5xa8nqbw5n1x9bpm4")
        (npm-tarball "entities/-/entities-7.0.1.tgz"
                     "1843sjzia0074bh93aighhlnhz6p8bx12h3i742dm7psg4m7wjsm")
        (npm-tarball "env-paths/-/env-paths-2.2.1.tgz"
                     "17knwv8glmap1vcgca11h1r48hyards94slc83y9z02q857qj2ss")
        (npm-tarball "err-code/-/err-code-2.0.3.tgz"
                     "1qj8n8paszjn4w39wgd19885wp49hj98fd8hlp7isbqm0i54yrm5")
        (npm-tarball "es-define-property/-/es-define-property-1.0.1.tgz"
                     "1xw50gnqd3d7nyfcl5a5lzrhxa0sjq7qyzaw1n5hld1166qvi1jr")
        (npm-tarball "es-errors/-/es-errors-1.3.0.tgz"
                     "14q935xgv4cblmy8lk3brx4ypwxpgrid77r1lfnbilsbbg1x2kfi")
        (npm-tarball "es-module-lexer/-/es-module-lexer-1.7.0.tgz"
                     "1y95zrbvpl4k0wgbpdx58gvz95ag26611g5zqlgqgi9wmis2w6z4")
        (npm-tarball "es-object-atoms/-/es-object-atoms-1.1.1.tgz"
                     "1kkrwpp6nz2nc32zxin52xnngyg7qg38c5ljy5xyx2l1azby861y")
        (npm-tarball "es-set-tostringtag/-/es-set-tostringtag-2.1.0.tgz"
                     "0gdrn28p1xnj8j98b6f1sf15xy4h0cd38alazwml1vikbhdgaxan")
        (npm-tarball "es6-error/-/es6-error-4.1.1.tgz"
                     "0ylrhncxyzvw5nrpasrn5cxsgx5x2522vf8fwprv5bs80nvsw2p1")
        (npm-tarball "esbuild/-/esbuild-0.27.4.tgz"
                     "1afypczvwzjyiqf5nvrna9himmk6zxk3cnnbfda8p0qsfpl562dd")
        (npm-tarball "escalade/-/escalade-3.2.0.tgz"
                     "1rxy0388xsgxam8limnbxhksa1z1xccd47vi4r9p1ip6q2pma9xs")
        (npm-tarball "escape-html/-/escape-html-1.0.3.tgz"
                     "0rh35dvab1wbp87dy1m6rynbcb9rbs5kry7jk17ixyxx7if1a0d1")
        (npm-tarball "escape-string-regexp/-/escape-string-regexp-4.0.0.tgz"
                     "06xi6f77ybg7cl673bawycpp6984h2ridzy2hl2kqylqlr6s2i2b")
        (npm-tarball "estree-walker/-/estree-walker-2.0.2.tgz"
                     "0n1wn3ii6q3dcjy2sbsawsysgyad1hlijhb3as6mdid977jk2a9h")
        (npm-tarball "estree-walker/-/estree-walker-3.0.3.tgz"
                     "1cvj3jfzlrg1dskkcwbjaccc00s16jma8mag8yg0kvyrdk0zvgdv")
        (npm-tarball "etag/-/etag-1.8.1.tgz"
                     "1bqgznlsrqcmxnhmnqkhwzcrqfaalxmfxzly1ikaplkkm5w6ragn")
        (npm-tarball "event-target-shim/-/event-target-shim-5.0.1.tgz"
                     "1g16bd7qlk5q6v23k52fq4xc4na9f8ind4365swh7iz5rni7swgh")
        (npm-tarball "eventemitter3/-/eventemitter3-2.0.3.tgz"
                     "0dhswiyxiqyys3mzdnp1vl8nh7s8a8b5y5vm8rwcmmjjfc739z5b")
        (npm-tarball "events-universal/-/events-universal-1.0.1.tgz"
                     "1snjpml0ss6bgs3p6cqajywiwh6cyhnvyjshwabyh2xk2lfl1w48")
        (npm-tarball "events/-/events-3.3.0.tgz"
                     "0jsk7gxx98816wg0nl4wfwljscbg7iv8ys68mbgrnaaq1dixsc1c")
        (npm-tarball "evp_bytestokey/-/evp_bytestokey-1.0.3.tgz"
                     "1qa0ghpk2w6gylbknlbb3mb90lw9sf1xafr7dy4gp17djrc182n1")
        (npm-tarball "execa/-/execa-9.6.1.tgz"
                     "17a3ic2h2xsgm2sxq99xrx8a4c4bk2baj7jkw6lf3mr81gx2wzbc")
        (npm-tarball "expect-type/-/expect-type-1.3.0.tgz"
                     "0fgj240ahldn8wmrkb7f32hxm4nmqvgd51y45ah3d0a2c30mnxrg")
        (npm-tarball "exponential-backoff/-/exponential-backoff-3.1.3.tgz"
                     "09imj5s3cg4n0ikisg11bnn8dmhjv3za3n2d60frkyjqwkrh1pif")
        (npm-tarball "express/-/express-5.2.1.tgz"
                     "01fhbm4bndc5d6sign60v8mh5xv828hlv74v8x9jchml09na2wqp")
        (npm-tarball "extend/-/extend-3.0.2.tgz"
                     "1ckjrzapv4awrafybcvq3n5rcqm6ljswfdx97wibl355zaqd148x")
        (npm-tarball "extract-zip/-/extract-zip-2.0.1.tgz"
                     "1d6sffrprp0na74i7yaprqhdhlr2n3znws509jv7nqgscypf1d2r")
        (npm-tarball "fast-deep-equal/-/fast-deep-equal-3.1.3.tgz"
                     "13vvwib6za4zh7054n3fg86y127ig3jb0djqz31qsqr71yca06dh")
        (npm-tarball "fast-diff/-/fast-diff-1.1.2.tgz"
                     "1qpgy12z064m5mzb9fl2xp1dzz1if7adljcb04z283xl7jng5iv7")
        (npm-tarball "fast-diff/-/fast-diff-1.3.0.tgz"
                     "0jkxa4f3c7adj66x991da13h1p1kd5ivmnaxzd6qzxk66gc05xkp")
        (npm-tarball "fast-fifo/-/fast-fifo-1.3.2.tgz"
                     "0jjpyvjzhzi9hxczql8gss5gfagfil8ggadk54vx21lsd2avq7d7")
        (npm-tarball "fast-string-truncated-width/-/fast-string-truncated-width-3.0.3.tgz"
                     "1cay7d986m3yy4rkh8ybcn54n4jjj10j1fjxxm9v8w1l88swxnmm")
        (npm-tarball "fast-string-width/-/fast-string-width-3.0.2.tgz"
                     "0akmnc694qnsl8vdmiargfh9va9wd1i5zzr7l9ahx6r0vw9z3nkj")
        (npm-tarball "fast-uri/-/fast-uri-3.1.0.tgz"
                     "07aqhdd91rygicxava81j74gz5isg3656x3vhrgivk6q9dmkrlrs")
        (npm-tarball "fast-wrap-ansi/-/fast-wrap-ansi-0.2.0.tgz"
                     "0y5jiyvkc33f6qk489xyk342m08j2hc584y9hlvi3h4x36vf2lzv")
        (npm-tarball "fd-slicer/-/fd-slicer-1.1.0.tgz"
                     "08w8mwdkaadagyhh61cppma7a4l9z13rlbrxz14ys6r7xfp26s6c")
        (npm-tarball "fdir/-/fdir-6.5.0.tgz"
                     "0pin1ngw51v3z7q8gs4q84bwwcw3pdyh29jk8351yahyygcxq794")
        (npm-tarball "fflate/-/fflate-0.8.2.tgz"
                     "1p21s6c9kk613jzyqjxzw49s6y5xqzzg5xr964z5x3pww9hm1zb1")
        (npm-tarball "figures/-/figures-6.1.0.tgz"
                     "1z0xwlwg029qbdrfvawjhh4b995px8b848qxc7sxv498fxf1byrh")
        (npm-tarball "filelist/-/filelist-1.0.6.tgz"
                     "00zhfi49a40lahnldrlky9a08m3vxnysliamh5ksmrhdbqkp0qqj")
        (npm-tarball "finalhandler/-/finalhandler-2.1.1.tgz"
                     "0wmqm14f4xd6gf6s6117sn0xgvx935bdcrxyidcv6856a7y9p512")
        (npm-tarball "find-up/-/find-up-5.0.0.tgz"
                     "1d3mr9ifkyz3dljjm6gr6av87a3s7zyn66fq72bc0s9pb3xlx9pl")
        (npm-tarball "flat/-/flat-5.0.2.tgz"
                     "0hpdzvw1jrpvvhiibwa3sgjlk49xfirihd8cjhyjnphcz91dwwnp")
        (npm-tarball "floating-vue/-/floating-vue-5.2.2.tgz"
                     "04pi0n4fw20mf4g5lxkhc4ca4s14dpsw7nmfncvhnvivj5xarwl7")
        (npm-tarball "follow-redirects/-/follow-redirects-1.15.11.tgz"
                     "10wjpk38fyk1q4shx6ph8slwhdajpm6fb9n5vxfacbpqggh3x1hc")
        (npm-tarball "for-each/-/for-each-0.3.5.tgz"
                     "1lc5f4l4zym84c903v2b688gm273v1pkvgdkmgvkrjblwv4czljb")
        (npm-tarball "foreground-child/-/foreground-child-3.3.1.tgz"
                     "0gk7q5awnicb8p2ad6i0m84vrw0vylda1x0vq2nrq12hn1dwm75g")
        (npm-tarball "form-data/-/form-data-4.0.5.tgz"
                     "1j4sxhj265q0amxab070wpqfmdyprigiwnk4rlm48x83939v2la1")
        (npm-tarball "forwarded/-/forwarded-0.2.0.tgz"
                     "168w8dhfqp12llh2w802dm3z1fcarsacsksyvdccnpxqbzlmsnlv")
        (npm-tarball "fraction.js/-/fraction.js-5.3.4.tgz"
                     "0951aj5ci888vr4a6w8zpr53afcpsd8zrgp42cg591fjba73vqi7")
        (npm-tarball "fresh/-/fresh-2.0.0.tgz"
                     "1mvs4wihlr6bw05h7q12771qrkwrssm26bk80ysv4qjzn1x3j25d")
        (npm-tarball "fs-extra/-/fs-extra-10.1.0.tgz"
                     "1shzjwi0jj6haqwji5mc45nb08gw0zyq6gy26mmv0sw65s2ngajh")
        (npm-tarball "fs-extra/-/fs-extra-11.3.4.tgz"
                     "0q06j752sfhxq784n19smkfpdpb3qbiv6959qm1hfpmm0gsyv769")
        (npm-tarball "fs-extra/-/fs-extra-7.0.1.tgz"
                     "1f08bng4dgkdrwhd977f4xfch9419b7fbwvwwn1qpz3gy4zgja4b")
        (npm-tarball "fs-extra/-/fs-extra-8.1.0.tgz"
                     "0n5ibswj8njpw8w8igfqxklyips6m1y8cyk1zrd9llv9rirlgv00")
        (npm-tarball "fs-extra/-/fs-extra-9.1.0.tgz"
                     "0fniby4ck1ihrbwkjfgpdxcci03hrn1p938c333298gcs6hzhw1x")
        (npm-tarball "fs-minipass/-/fs-minipass-2.1.0.tgz"
                     "029kdjb6h8gp0gfx7rx6yzwbv7pnd7i119gn563ynv0dqx02p5gx")
        (npm-tarball "fs-minipass/-/fs-minipass-3.0.3.tgz"
                     "0n3a81cxq9nwjyrp5yyap7faqxmkwc4449dy4vc4lkmispfrhga1")
        (npm-tarball "fs.realpath/-/fs.realpath-1.0.0.tgz"
                     "174g5vay9jnd7h5q8hfdw6dnmwl1gdpn4a8sz0ysanhj2f3wp04y")
        (npm-tarball "fstream/-/fstream-1.0.12.tgz"
                     "0r3m7cl7wqfgkm8wzrvm2fl4wl0dwzbz2yh6aw3gd2zka3jyg5vk")
        (npm-tarball "function-bind/-/function-bind-1.1.2.tgz"
                     "1ah7x13hmwwfslk72h2rs21c5vqnsxyzqifl2x7lb8823djh4i3h")
        (npm-tarball "functions-have-names/-/functions-have-names-1.2.3.tgz"
                     "1p5iz84vhxa1b9cfqhdhqgz746lg2ahmcsiz7q4m6z3g02fckq1v")
        (npm-tarball "generator-function/-/generator-function-2.0.1.tgz"
                     "0rnb98cimpvc94k3sx8gswaqlq3r9h63hl1gr2ak5idm2ygm6zc1")
        (npm-tarball "gensync/-/gensync-1.0.0-beta.2.tgz"
                     "1j8piprq5pvns7j60gm0jkrdmnm8zrfl2wwarf94ypd34vpr57yz")
        (npm-tarball "get-caller-file/-/get-caller-file-1.0.3.tgz"
                     "0s1b558j1an7g0y5kvbvyailjbxsqgk7374cbb07h26gkwbhc14x")
        (npm-tarball "get-caller-file/-/get-caller-file-2.0.5.tgz"
                     "0pwk4r8iyyq2j0xpxavdm3ldb4h4k4s4xb74m8dlrzs9374f24vv")
        (npm-tarball "get-east-asian-width/-/get-east-asian-width-1.5.0.tgz"
                     "0f2y33mm6bphn6xwg8gv7gi11il7pxcfir1an7kgqzryv6j6fbg8")
        (npm-tarball "get-intrinsic/-/get-intrinsic-1.3.0.tgz"
                     "0i05g3xvqgv16ss19k3jprfnkqsln2n4m7wgn3xldzh09vjjfbk6")
        (npm-tarball "get-proto/-/get-proto-1.0.1.tgz"
                     "1086swsp92367j7m6canvgf6zwghh0iqr9f2bwndh7qzzcmcab7b")
        (npm-tarball "get-stream/-/get-stream-5.2.0.tgz"
                     "077iv0jqfgqyxw6jb0iradw9idjcmphmrc58zj050vf58yx0bzkr")
        (npm-tarball "get-stream/-/get-stream-9.0.1.tgz"
                     "1ii445ia39i2qlcavinywlw0qx9k3ggkcabps00qzqqcfdnnyrwf")
        (npm-tarball "get-tsconfig/-/get-tsconfig-4.13.7.tgz"
                     "1jz66cyq7p8p8hdc14g1d8rg0gcbws5i18vkrqdabw700qxh3v8z")
        (npm-tarball "github-markdown-css/-/github-markdown-css-5.9.0.tgz"
                     "1d1kaabzzkqdfw338varbvn2bipjqsbv93cc6j56lhh9cy0jh6i9")
        (npm-tarball "glob-parent/-/glob-parent-6.0.2.tgz"
                     "0rjhim72pkv230y79xdahhpcnhy4y8fxr7dhr8sf47xyyd1bjnrl")
        (npm-tarball "glob/-/glob-10.5.0.tgz"
                     "00h8dss5np41v0ciq00y5wcd6c9w044wvk6annx0i33cqswmrdqq")
        (npm-tarball "glob/-/glob-13.0.6.tgz"
                     "0w49ggh984wkrj0myy3gbzh5hnmjljxisg9wydf91qn4m57ih3q2")
        (npm-tarball "glob/-/glob-7.2.3.tgz"
                     "10a336nxv867xkjs3ipgbharwdzp5lnz7wr8viawn1lc66qqx8zh")
        (npm-tarball "global-agent/-/global-agent-3.0.0.tgz"
                     "1acy97l5xlaiakqkacb35qwf0cfb5zqgxld05d30y5nd5k7pb2f3")
        (npm-tarball "globalthis/-/globalthis-1.0.4.tgz"
                     "1svnf2ha7rnfv04l6b1i8jilpzg4lb9fsz44kkijlp3g7hwdm66y")
        (npm-tarball "gopd/-/gopd-1.2.0.tgz"
                     "10nskxn4cwbfd9i9nzy2r7pf0zm46j9z7dzvd0adr1fj9pgd0dnm")
        (npm-tarball "got/-/got-11.8.6.tgz"
                     "00x52m4xidmkhn2gz3v2hn39vp5hyg0n70r15a3rx98z3gbvxkq2")
        (npm-tarball "graceful-fs/-/graceful-fs-4.2.11.tgz"
                     "1709vla02prpbf34xqsvkqngvsmp5ypnljvg1pcgxrk1l553fq9r")
        (npm-tarball "h3/-/h3-1.15.10.tgz"
                     "0q4xgyyj52a52wc87r7hxy5i2w8ppdpf3kv1vhlc3vh79a9pdwxj")
        (npm-tarball "harmony-reflect/-/harmony-reflect-1.6.2.tgz"
                     "0jnh7n4gl3i3pf9n4glwwppzr9v11hcjsybmqmf9vnavkgjykm98")
        (npm-tarball "has-flag/-/has-flag-4.0.0.tgz"
                     "1cdmvliwz8h02nwg0ipli0ydd1l82sz9s1m7bj5bn9yr24afp9vp")
        (npm-tarball "has-property-descriptors/-/has-property-descriptors-1.0.2.tgz"
                     "11zsidd9sb9v0bzq7ia9iw4h5mgjdwn5mxgzdvmqw9ifygcbn682")
        (npm-tarball "has-symbols/-/has-symbols-1.1.0.tgz"
                     "1ig7dbwgg0kbjg2wc7arp7a28g6l2rwc27lsvhnxzf185x9wfq24")
        (npm-tarball "has-tostringtag/-/has-tostringtag-1.0.2.tgz"
                     "0yzgy2kkf5z4w3x68r1ymm3aln7ji4ndfis7z1qn56hpy7ip876w")
        (npm-tarball "hash-base/-/hash-base-3.0.5.tgz"
                     "1vin0npl0b407lzxjmyqj9fdzmww7rh6pa9q5409ncrk8ikfd6l7")
        (npm-tarball "hash-base/-/hash-base-3.1.2.tgz"
                     "03gbnj9g1qf2k552pv054v34rmgg5iq0kc4v749hbjm8fwhnjlyr")
        (npm-tarball "hash.js/-/hash.js-1.1.7.tgz"
                     "19lccrqxgndiwfcpv1xzmapmwr74rydbzm2ynvnjy19kpl6gxbcf")
        (npm-tarball "hasown/-/hasown-2.0.2.tgz"
                     "0zc0za6zy8y2iwy31ayzwmi4j912j382iwr9xsv09bhirp9c9kah")
        (npm-tarball "he/-/he-1.2.0.tgz"
                     "0s0v3k8xgrcdch31p0ig12qkdfzdbk66s4rqhsz0nv0v1h1pqykp")
        (npm-tarball "highlight.js/-/highlight.js-10.7.3.tgz"
                     "07m9prr3bz7vygcl80kfbwg65pwvinlp6k9fvl7r2vqh3p1nha99")
        (npm-tarball "highlight.js/-/highlight.js-9.18.5.tgz"
                     "17rgzj5dzmwbzlsgfcal3vp6cfjn2c1dqkv2qa0273z8prwxkiqz")
        (npm-tarball "hmac-drbg/-/hmac-drbg-1.0.1.tgz"
                     "0qjrwdicm82v3amswcbjgfa3lvfy7kv29wffvz5mb6m473cp04rj")
        (npm-tarball "hookable/-/hookable-5.5.3.tgz"
                     "1wxag17k08c4rv86mh14dfkh3w5dnj539c9r09r3rdcncvry5g7g")
        (npm-tarball "hosted-git-info/-/hosted-git-info-4.1.0.tgz"
                     "1pjzmqa9nz5pbmqa3mg24d0xv301wqbzgk71rfz9l7warz5z9zxq")
        (npm-tarball "html-minifier-terser/-/html-minifier-terser-7.2.0.tgz"
                     "00xd3yjc6765qvw7n0gid99wcf5jpa35x9id1py8b644rjcvnizb")
        (npm-tarball "http-cache-semantics/-/http-cache-semantics-4.2.0.tgz"
                     "1dqfv0xk3fm9zz6ypvz0gq5s10a1mmq7ryxvm95nml5jibdm8x7m")
        (npm-tarball "http-errors/-/http-errors-2.0.1.tgz"
                     "0qbc38g805qi9bcywg082sz8kdgxkq4fssgjlfcrc1xg3fqvnqmd")
        (npm-tarball "http-proxy-agent/-/http-proxy-agent-7.0.2.tgz"
                     "00kgi96l0vs04g2vl2xw3g53saxb4n9za2x23pbaiyrbm7x76pvq")
        (npm-tarball "http2-wrapper/-/http2-wrapper-1.0.3.tgz"
                     "07l26r82ixnlr5775afcw6a03c2bmih8z8lymc3izd5qgckrw7gx")
        (npm-tarball "https-browserify/-/https-browserify-1.0.0.tgz"
                     "1g07h6f4jggajdsf0ijcdl8xnm935sxq3l6dl91hqg7dfq34vwfl")
        (npm-tarball "https-proxy-agent/-/https-proxy-agent-7.0.6.tgz"
                     "1q603cjw6z348j2i7k7s5zb3kp91hi9lml298bv84214wpl8j3wn")
        (npm-tarball "human-signals/-/human-signals-8.0.1.tgz"
                     "1xnl55qynw3yl5q89bqchsf1nrasbjjv6v15c3gc6s9x07cpwfdj")
        (npm-tarball "humanize-plus/-/humanize-plus-1.8.2.tgz"
                     "11myaxf5iz4zyzv4ymf1valnf31v3b9qbnc98qbvc4i8md9y29mq")
        (npm-tarball "iconv-lite/-/iconv-lite-0.6.3.tgz"
                     "1x681ziwavjjn09j4858fl3h3xi90vf512k5zwg06kwriwafq9vi")
        (npm-tarball "iconv-lite/-/iconv-lite-0.7.2.tgz"
                     "0gm0im7640vi4j29ssh9zf1ynfrffkjm4mig9np3b4hzwxlngm31")
        (npm-tarball "identity-obj-proxy/-/identity-obj-proxy-3.0.0.tgz"
                     "0rgrpic77wpa98hgkqwx4y7w70kbcv5i1q7yp7hz285mgazhrndw")
        (npm-tarball "ieee754/-/ieee754-1.2.1.tgz"
                     "1b4xiyr6fmgl05cjgc8fiyfk2jagf7xq2y5rknw9scvy76dlpwcf")
        (npm-tarball "immediate/-/immediate-3.0.6.tgz"
                     "04cxfcl4zm2qfsrrd19n5w4w8k8309wl1k2xq0c0ic2hjvrr5iwq")
        (npm-tarball "immutable/-/immutable-5.1.5.tgz"
                     "19c2kp2pfz3wf7792x1fggn3iamksyb7nvmz91i7g6qknppciz84")
        (npm-tarball "imurmurhash/-/imurmurhash-0.1.4.tgz"
                     "0q6bf91h2g5dhvcdss74sjvp5irimd97hp73jb8p2wvajqqs08xc")
        (npm-tarball "inflight/-/inflight-1.0.6.tgz"
                     "16w864087xsh3q7f5gm3754s7bpsb9fq3dhknk9nmbvlk3sxr7ss")
        (npm-tarball "inherits/-/inherits-2.0.4.tgz"
                     "1bxg4igfni2hymabg8bkw86wd3qhhzhsswran47sridk3dnbqkfr")
        (npm-tarball "ini/-/ini-1.3.8.tgz"
                     "0nk92bp5is23lsi1ip4qz5bjkzmjxkz9c1g79sx991ad212i37px")
        (npm-tarball "inquirer/-/inquirer-13.3.2.tgz"
                     "090cl0ynmrsnwdy841c3aa8ay3kw18z7d81is1s1zw4k3fz7m33p")
        (npm-tarball "ip-address/-/ip-address-10.1.0.tgz"
                     "1r53sbb46cp6dc17i8h49m9nlphz155hiqrpw0mv76vpnc10awmn")
        (npm-tarball "ip/-/ip-2.0.1.tgz"
                     "1ja3rnqwzf1fxwfar844djdsgazyhmvh0dq688h1n7hk53pmy4hx")
        (npm-tarball "ipaddr.js/-/ipaddr.js-1.9.1.tgz"
                     "1vlg9vgdlx13dvh6h6sg3rgdbp04lkljmn6gxih43zk77xidjhbl")
        (npm-tarball "iron-webcrypto/-/iron-webcrypto-1.2.1.tgz"
                     "1z973h51vjgny3jlz2lfmnqh114m598yvbl8p3jpjrnc753yxwlf")
        (npm-tarball "is-arguments/-/is-arguments-1.2.0.tgz"
                     "0775n33i4zh211v9n9p403z8y7334w5cfvsp9mlipxf4krwjjv27")
        (npm-tarball "is-callable/-/is-callable-1.2.7.tgz"
                     "18f30fsh8kckhfshfyfq98n4z9hbi2fvfbyagy2schmii976wp0v")
        (npm-tarball "is-core-module/-/is-core-module-2.16.1.tgz"
                     "1qrv78pa8rgvbzasixhvl0q7qf2izzsk1bnh9nvqvijasp8b3pg3")
        (npm-tarball "is-date-object/-/is-date-object-1.1.0.tgz"
                     "0mh20gz9b6as4gccyavvw3xqs4h51gryd359pcisq5hfqsk0cmvz")
        (npm-tarball "is-docker/-/is-docker-3.0.0.tgz"
                     "1vnxw8y4p31nx66rbgxhd40jc5zx8akmcf7fpl3gy7n84l5hn8qs")
        (npm-tarball "is-extglob/-/is-extglob-2.1.1.tgz"
                     "06dwa2xzjx6az40wlvwj11vican2w46710b9170jzmka2j344pcc")
        (npm-tarball "is-fullwidth-code-point/-/is-fullwidth-code-point-3.0.0.tgz"
                     "0jmw03rxmbwbrkx0a8wq05qsjhdrx9jn3vns88dhy1y6bnp5shbg")
        (npm-tarball "is-generator-function/-/is-generator-function-1.1.2.tgz"
                     "1l03v20ipkmq09xdi2irvz8mdb8zmvlk4d00hp4plhljh03xpdhi")
        (npm-tarball "is-glob/-/is-glob-4.0.3.tgz"
                     "1imyq6pjl716cjc1ypmmnn0574rh28av3pq50mpqzd9v37xm7r1z")
        (npm-tarball "is-in-ssh/-/is-in-ssh-1.0.0.tgz"
                     "0m6r0p35lv8prm60i7sivbz3606yhsbjv3s0pmqqvzjl33j9l5fd")
        (npm-tarball "is-inside-container/-/is-inside-container-1.0.0.tgz"
                     "0yz0fbbkypqsx5d5cls1ik8928zkqhwl2kcp4iv7bi2g8fw9bpnv")
        (npm-tarball "is-interactive/-/is-interactive-1.0.0.tgz"
                     "194g35nginih951q6i1wvfk3wpff3kdrxn5hpzrjwjjmv1wqk11c")
        (npm-tarball "is-nan/-/is-nan-1.3.2.tgz"
                     "0lw6c8m3y3jcaabjddigca3ca9hmqa7wqfmdg64kkkf532c6z9ph")
        (npm-tarball "is-obj/-/is-obj-2.0.0.tgz"
                     "06vnwn97ms8y6xjl9nck80whc1jqz2iby73n5z1qd41k8mv5m9xh")
        (npm-tarball "is-plain-obj/-/is-plain-obj-4.1.0.tgz"
                     "1xr1ws5y464sf7if4zrk0fjxws4p1xwwx05h541mdkdpg97qf7f7")
        (npm-tarball "is-plain-object/-/is-plain-object-2.0.4.tgz"
                     "1ipx9y0c1kmq6irjxix6vcxfax6ilnns9pkgjc6cq8ygnyagv4s8")
        (npm-tarball "is-promise/-/is-promise-4.0.0.tgz"
                     "19s5njn24k6ra9c4skkzjhjfaq0d1izkxxicfsw07ykn70br2f45")
        (npm-tarball "is-regex/-/is-regex-1.2.1.tgz"
                     "03cbm4iy3j9z4mbhvm895dhra7x045zsf6qg3wnzh6k2af8ljgm7")
        (npm-tarball "is-stream/-/is-stream-2.0.1.tgz"
                     "1mxnc5nlh73zg34vwdd9k5mx2wcs5pc84j8a2yig2y0bl9rgy09m")
        (npm-tarball "is-stream/-/is-stream-4.0.1.tgz"
                     "06cd55gjr6kbjwr0hryvmkiqdac4cxf7lfmk42hllcnph7aarx5q")
        (npm-tarball "is-typed-array/-/is-typed-array-1.1.15.tgz"
                     "143nrdwvdnxh1yc3qvb15ms6s3wpbgj3g1pq2v49bqwc40ln5vyi")
        (npm-tarball "is-unicode-supported/-/is-unicode-supported-0.1.0.tgz"
                     "1gnakv580clcgcmh0nqrwqy53sdnrv4vglgixd2w8bic4bzgw5bw")
        (npm-tarball "is-unicode-supported/-/is-unicode-supported-2.1.0.tgz"
                     "0qnkzlhkxra98ahzbpcr0w3sd2h22wrffn26gg5zjbz61r0c09jr")
        (npm-tarball "is-url/-/is-url-1.2.4.tgz"
                     "1ycq4fzpfjf645jqmkb9ps97xxslyilh339wyffjkpl2yks3ap20")
        (npm-tarball "is-what/-/is-what-5.5.0.tgz"
                     "0vpsny5npijpv519bjqivlgm95wwdvvzyxnmi5m52ni3hk6nrmlh")
        (npm-tarball "is-wsl/-/is-wsl-3.1.1.tgz"
                     "1cifp5r1mabbd24d1b81xgnh7dy0js7vwnx3hyj6iry2jsbkzygh")
        (npm-tarball "isarray/-/isarray-1.0.0.tgz"
                     "11qcjpdzigcwcprhv7nyarlzjcwf3sv5i66q75zf08jj9zqpcg72")
        (npm-tarball "isarray/-/isarray-2.0.5.tgz"
                     "14zpnpwcjxi86qgjv9lxbcaqv6zffqn0204c2554nq0sp1iy9fkj")
        (npm-tarball "isbinaryfile/-/isbinaryfile-4.0.10.tgz"
                     "0jwgr66c9qv2jnibvhahqpqqj99h39ch16gzyn8dwqprbbq887wg")
        (npm-tarball "isbinaryfile/-/isbinaryfile-5.0.7.tgz"
                     "1llrlh509l1278n73rhf388s9kkam1v2z9vnrjc6gg4i10l7i30v")
        (npm-tarball "isexe/-/isexe-2.0.0.tgz"
                     "0nc3rcqjgyb9yyqajwlzzhfcqmsb682z7zinnx9qrql8w1rfiks7")
        (npm-tarball "isexe/-/isexe-3.1.5.tgz"
                     "04988s0j8lglw09g9izzl8xwr20y6v5ifpc012yzp6dj62hiw1pf")
        (npm-tarball "isobject/-/isobject-3.0.1.tgz"
                     "0dvx6rhjj5b9q7fcjg24lfy2nr3a1d2ypqy9zf9lqr2s00mwkiiw")
        (npm-tarball "isomorphic-timers-promises/-/isomorphic-timers-promises-1.0.1.tgz"
                     "134m9bmag8mld3wfpnaiqy4mziir75ki8z71nssz89kbkvxpy686")
        (npm-tarball "jackspeak/-/jackspeak-3.4.3.tgz"
                     "0k1f8jj9nd2v0pnxx7hnbrr5k891lj7v73hbcxa3hhy0bwhyibfx")
        (npm-tarball "jake/-/jake-10.9.4.tgz"
                     "1mzsdqak7cln2nrdz12cd8s8x73jsrs1m4g35iw803hkf3rp0hm6")
        (npm-tarball "jiti/-/jiti-2.7.0.tgz"
                     "1ji8rzdyqd7w8r1hk4j4q9phba9dzgv0v86n8b6fgh29zdjx7l4d")
        (npm-tarball "js-base64/-/js-base64-3.7.8.tgz"
                     "0811ma64cmpsr0xsh38cx989cdswfb0dbfcgyf7sbw3rwz6117f9")
        (npm-tarball "js-beautify/-/js-beautify-1.15.4.tgz"
                     "19nr64gf8gphlirvbxi2ab00h84l9yy4rz3rs64yfrwlgi1zpvjz")
        (npm-tarball "js-cookie/-/js-cookie-3.0.5.tgz"
                     "0x9h0rrcsp60ilcgscw1yf3068ha212dqdh0la8hznzgq62fkaip")
        (npm-tarball "js-tokens/-/js-tokens-4.0.0.tgz"
                     "0lrw3qvcfmxrwwi7p7ng4r17yw32ki7jpnbj2a65ddddv2icg16q")
        (npm-tarball "js-tokens/-/js-tokens-9.0.1.tgz"
                     "0qqw4ic8jj5lv85wg2pa2a54a7jn2a817cfdnz0ir3s36r9i7dj4")
        (npm-tarball "js-yaml/-/js-yaml-4.1.1.tgz"
                     "0vs3026pccdw26vwwnan1k6n43mji4nsc14yggg2vdjggmh830cl")
        (npm-tarball "jsesc/-/jsesc-3.1.0.tgz"
                     "029w1pc3jck2y6bg2g9vvz3mij38l992zb7jhfzp16narhjj4w8c")
        (npm-tarball "json-buffer/-/json-buffer-3.0.1.tgz"
                     "19gmzrfyy4k7sckqgc3gsz5hpkjg6gg75nhrr5rmyg3ip56ldxyi")
        (npm-tarball "json-schema-traverse/-/json-schema-traverse-1.0.0.tgz"
                     "08cvg5wysj4r0ax2lvhx7j74l7da8w75klz5pmsc57zj5mi24ch2")
        (npm-tarball "json-stringify-safe/-/json-stringify-safe-5.0.1.tgz"
                     "12ljc7ipy7cprz5zxzzds20ykw6z5616763ca5zx9xmzq1jvzyxp")
        (npm-tarball "json5/-/json5-2.2.3.tgz"
                     "0yrpsb1frqahc48n6w2jzvhd7m8r9w2w9ylqkg41zl80nqyv7bq8")
        (npm-tarball "jsonfile/-/jsonfile-4.0.0.tgz"
                     "1s701cy3mlbvgyhhyy2ypqcy064w5990sk8x81gv0200yybrbfaz")
        (npm-tarball "jsonfile/-/jsonfile-6.2.0.tgz"
                     "0blkjhh096s97995rd8z13m962m7jj8zaw69q33bd97zfvkww0lh")
        (npm-tarball "jszip/-/jszip-3.10.1.tgz"
                     "08qvnasvaajkjkjr2lp7jz63b0fmb9brr0ivpw3v7bj5lsig85si")
        (npm-tarball "just-extend/-/just-extend-6.2.0.tgz"
                     "0p76mbmwn0ilzh8m7r63amd87ijikjmpjp4awl154nya9f9cvwa0")
        (npm-tarball "keyboardevent-from-electron-accelerator/-/keyboardevent-from-electron-accelerator-2.0.0.tgz"
                     "0dmpn6vv2g64pahi6mbckpj1rcyzbs869wdb00pxjgqb23ga45xc")
        (npm-tarball "keyboardevents-areequal/-/keyboardevents-areequal-0.2.2.tgz"
                     "1gni3dmbifkhfqfl9b131f3lqccg55ad4wn3q5gb1fwg849xmc33")
        (npm-tarball "keyv/-/keyv-4.5.4.tgz"
                     "1630gds0l00zmx2kiaa76ybf6ig7ygsm8ssy6sjg8yp5c72z29pb")
        (npm-tarball "kind-of/-/kind-of-6.0.3.tgz"
                     "1nk31q65n9hcmbp16mbn55siqnf44wn1x71rrqyjv9bcbcxl893c")
        (npm-tarball "kolorist/-/kolorist-1.8.0.tgz"
                     "1cly7kf88j9pglj3chp2n61bcfphiby4d9rcsg9g85512clxbbi2")
        (npm-tarball "lazy-val/-/lazy-val-1.0.5.tgz"
                     "0wjk8d0mw86wpbvizvqkl2bn36fx64wbyvxlspxijgfvk2nh51kx")
        (npm-tarball "lazystream/-/lazystream-1.0.1.tgz"
                     "16kdggfv5zks4cpx6afasqpfwpl7vf8rxyh2kvk17s3qs2120lh8")
        (npm-tarball "lie/-/lie-3.3.0.tgz"
                     "0vm3wrzfrjmv2qjcf6fch7znad6k6kd5b34cb31jy3m1shf4df1d")
        (npm-tarball "lightningcss-linux-x64-gnu/-/lightningcss-linux-x64-gnu-1.32.0.tgz"
                     "02ri7hh6c41j3pfvhv9sbpv6pqjqs46mj506nlaa9pfs61i4cvwy")
        (npm-tarball "lightningcss-linux-x64-musl/-/lightningcss-linux-x64-musl-1.32.0.tgz"
                     "11aj18ihs92hg7lg0b7bm3sq8fs70zzpr4yvpzzv82b6di0ay5sj")
        (npm-tarball "lightningcss/-/lightningcss-1.32.0.tgz"
                     "1s2h2ndakhgsjbm9zam4b0fr7l7hi1khlikpb2f437iw47m82gn8")
        (npm-tarball "listenercount/-/listenercount-1.0.1.tgz"
                     "1kahapbdk5xi5njdjh93xsj17w4sykknq8yw7d9dnp32srnr6kyx")
        (npm-tarball "locate-path/-/locate-path-6.0.0.tgz"
                     "0al3dmihydmwr89wc4ivqnkww7gm9p2ysq57j5qrj6sq8ckhplki")
        (npm-tarball "lodash.clonedeep/-/lodash.clonedeep-4.5.0.tgz"
                     "04h3zvxqwr3l6591q06vr87al81d5fbydz17pphp7jvgvkfk0dnd")
        (npm-tarball "lodash.debounce/-/lodash.debounce-4.0.8.tgz"
                     "180bk3h6nm2kvnn4f6phvcr0qyg5kj30ixrgflng352ndx63h655")
        (npm-tarball "lodash.escaperegexp/-/lodash.escaperegexp-4.1.2.tgz"
                     "0fj8ij578wkbyakvx7br0q42868rshmcvbmb2zckj6h3i119mr0p")
        (npm-tarball "lodash.get/-/lodash.get-4.4.2.tgz"
                     "16x492caalx0y2z91pmx3vrx6y0vw56z020b6vlgyv0mp2hynkfz")
        (npm-tarball "lodash.isequal/-/lodash.isequal-4.5.0.tgz"
                     "0y22hfws19nwmqg6jm9sqb9i7spsnjg7fmnf506avjl5ajjk9dd3")
        (npm-tarball "lodash/-/lodash-4.17.23.tgz"
                     "1d6filg5wdsqw90dy4l8symks50jjmg0ixydg3ksims49dgnifls")
        (npm-tarball "log-symbols/-/log-symbols-4.1.0.tgz"
                     "08qkf3cqwbi8azqxk2mz2mkfpndw71kklyk4x70a8aqvq6m0drrj")
        (npm-tarball "loupe/-/loupe-3.2.1.tgz"
                     "0dznc8l1s62svp8gn3vvlcgfp83v6xdizcz9905qkdqf4byvx3dg")
        (npm-tarball "lower-case/-/lower-case-2.0.2.tgz"
                     "0cghksa0pvk28iipmx759cb2jr71mbyj86rh25j6n6gzvxn9ciay")
        (npm-tarball "lowercase-keys/-/lowercase-keys-2.0.0.tgz"
                     "0l9vf2m7zz1hw8s0l2njhk3b128mq0z27z17dgpmk4ivcg181ij3")
        (npm-tarball "lru-cache/-/lru-cache-10.4.3.tgz"
                     "1vcnakqqjix4vgxpn49fkbf821fvj2msm9x79r8arapagd97p88f")
        (npm-tarball "lru-cache/-/lru-cache-11.2.7.tgz"
                     "16sd5biqdby622lm5h0qnglnidxlaz2lmy7ka2y4qglan7hwz01d")
        (npm-tarball "lru-cache/-/lru-cache-5.1.1.tgz"
                     "0nj8d71w5yb3rmiaxby5scwfl0n1jdaplr0p6dp619j4jn0ph7mi")
        (npm-tarball "lru-cache/-/lru-cache-6.0.0.tgz"
                     "0pnziizgv8jpg708ykywcjby0syjz1l2ll1j727rdxhw0gmhvr2w")
        (npm-tarball "magic-string/-/magic-string-0.30.21.tgz"
                     "0vv5mh4rnr83gnpd0kkspy1c810f4mfkczrjry64x96wcwjpcjgs")
        (npm-tarball "make-fetch-happen/-/make-fetch-happen-14.0.3.tgz"
                     "0aw4h2r1hgqdkg0vq3ivgd6hn9q9frk5j938blwg9z22njizy6sk")
        (npm-tarball "matcher/-/matcher-3.0.0.tgz"
                     "17sbpdkgfp24l1nr9qbxsih2sswbw08dam5xsvivfcg2z372hfxh")
        (npm-tarball "math-intrinsics/-/math-intrinsics-1.1.0.tgz"
                     "19s3yi9ziz007ymq0r1k2xk1nrg2m5lc9kw8vy3c0ga9fmaw7hmq")
        (npm-tarball "md5.js/-/md5.js-1.3.5.tgz"
                     "00rxd4al8zl7cf9bq6i0nhnj54pnv0444vscmdawfa8jn1hpnxq6")
        (npm-tarball "media-typer/-/media-typer-1.1.0.tgz"
                     "1ghrgjcv59qna3h37himz6p7qsby9vki3gjrnv7r5z0y3lg57p5m")
        (npm-tarball "merge-descriptors/-/merge-descriptors-2.0.0.tgz"
                     "1khx20ml70ll3k69qsq8p9ybz967mykrks8ak79m46f7bwm3525f")
        (npm-tarball "miller-rabin/-/miller-rabin-4.0.1.tgz"
                     "1jdqss21v5cmp1n17qxvmd3lp118x9qsjd768sjh820mlkkldg2m")
        (npm-tarball "mime-db/-/mime-db-1.52.0.tgz"
                     "0fwyiyqi3w03w3xwy2jhm8rsa0y9wgkc0j6q3q6mvk9asns0prxq")
        (npm-tarball "mime-db/-/mime-db-1.54.0.tgz"
                     "0864s7g498w1f95yvgq0ayqlgpb8x49jfb80qmcbvsnhcm70a89b")
        (npm-tarball "mime-types/-/mime-types-2.1.35.tgz"
                     "1hyi043kcqyfz82w19s357klvj54f0s94d40rymbms86i74lyws9")
        (npm-tarball "mime-types/-/mime-types-3.0.2.tgz"
                     "1b6j7px7npv0gli3v249m5a1rc2m8x3qxxpva23zy0y3af1x579g")
        (npm-tarball "mime/-/mime-2.6.0.tgz"
                     "0dmnrpwk42m7cr2v8knszz4qg1py6645jgbmha2smm1gxakil0dk")
        (npm-tarball "mimic-fn/-/mimic-fn-2.1.0.tgz"
                     "1gv60if81lf2gkwvgixgsx8p87ddhsf1aswkihmfzi462hk5qw7a")
        (npm-tarball "mimic-response/-/mimic-response-1.0.1.tgz"
                     "1s4cran004criblxk656ajagx924cy3wps608ksssyxc1qn01wa2")
        (npm-tarball "mimic-response/-/mimic-response-3.1.0.tgz"
                     "0m6xcg030cw88cja84avw63q3jkvqgbdp74xvs1p3m2w2my9n7ij")
        (npm-tarball "minimalistic-assert/-/minimalistic-assert-1.0.1.tgz"
                     "187k0gdixs2zqkfvv6lm72w90c15rin2kx2zkyly7nyn8z4j4rgi")
        (npm-tarball "minimalistic-crypto-utils/-/minimalistic-crypto-utils-1.0.1.tgz"
                     "1cwxzbk9zg7ha3pxcm4ghcy6j48jdpplisjgfvlddcp1xw16wpzk")
        (npm-tarball "minimatch/-/minimatch-10.2.4.tgz"
                     "0aamj8sng9lnnjd25bdw0cz7yxav7jhn6nnrc586qcln8l5w9ll9")
        (npm-tarball "minimatch/-/minimatch-10.2.5.tgz"
                     "1rd99j1d6x4lfb5ajnda6d16m7agx81x16qgwvxc7imz2mls9km6")
        (npm-tarball "minimatch/-/minimatch-3.1.5.tgz"
                     "0j66fa5bw8xrkiyl6p5g88d9wg4l5mshfi3jsg2wiqrdyzn1f66q")
        (npm-tarball "minimatch/-/minimatch-5.1.9.tgz"
                     "1zjcppmxxpyb652a3zsnmas009n2wrkhnqk1qrmbpjlzpb7xmrv7")
        (npm-tarball "minimatch/-/minimatch-9.0.9.tgz"
                     "0y04nhx30qi0ab8ipnr93mqy40qm928w33n7jch59khpxyiwja3x")
        (npm-tarball "minimist/-/minimist-1.2.8.tgz"
                     "10yfwkrl00d8gy9z622yrklg1jax3qk38j354jfw34xk2p0pc2im")
        (npm-tarball "minipass-collect/-/minipass-collect-2.0.1.tgz"
                     "15s0gi6jh9ax3i2403lnm2gki44yyaz772k0w51ab7qbi56hjk8s")
        (npm-tarball "minipass-fetch/-/minipass-fetch-4.0.1.tgz"
                     "0cxxa2c09xchq8f8d5af0pkcf3cfgc56mk0c0ivn09lw1rni5hkn")
        (npm-tarball "minipass-flush/-/minipass-flush-1.0.6.tgz"
                     "0ib6znf5jlhgidfnqck71g6hc03nlrrm79jvym5y37bi2r0hqqcq")
        (npm-tarball "minipass-pipeline/-/minipass-pipeline-1.2.4.tgz"
                     "13q7asqh62g3cdypm8rgvyq72crns331a9hqg6w92qzx68wg4r0b")
        (npm-tarball "minipass-sized/-/minipass-sized-1.0.3.tgz"
                     "1d9h3h6pnyr09381zyax0jr0k0wmx75qrfqdzbirrmhmcp5xiqjw")
        (npm-tarball "minipass/-/minipass-3.3.6.tgz"
                     "0pcyrxs22fnr6n1910qa7mpvdwfnxjvwnkwf5j04f6d28ds91lks")
        (npm-tarball "minipass/-/minipass-5.0.0.tgz"
                     "0gyp0rswjzj01mqapa714zw9h5m2jbynfcfz01g107wgdhc5hwdy")
        (npm-tarball "minipass/-/minipass-7.1.3.tgz"
                     "04kxs8if6f6vj9vkhhrnzp3y58fls2300mlfr7yy6m9pfjz63b2j")
        (npm-tarball "minizlib/-/minizlib-2.1.2.tgz"
                     "1vffn3i5ys3w74s8m8n4l7vvzijddi44flpaxdfv96q85n513va4")
        (npm-tarball "minizlib/-/minizlib-3.1.0.tgz"
                     "1qz2xkdz5zpr70z4g79pwb3ipxv81i4kfiv5y1qxswl1c4ljxgwr")
        (npm-tarball "mitt/-/mitt-3.0.1.tgz"
                     "01kkdp9ccd5jn728p9hr3y9ha5wciknhmcxqzn35pbbljmk9rxif")
        (npm-tarball "mkdirp/-/mkdirp-0.5.6.tgz"
                     "0sdmma4bm86i69b5p1didy3cass87rb0zjv35z0xs8sb0ld2ja8v")
        (npm-tarball "mkdirp/-/mkdirp-1.0.4.tgz"
                     "06nqac14zbpar89jc7s574l1qpmamr1kzy0dr3qyhvxg8570f5qx")
        (npm-tarball "mlly/-/mlly-1.8.2.tgz"
                     "1mvsmj4ixxq038zdikqn1mkadhnilazkjcg0g1iyp9h997kj1f3l")
        (npm-tarball "mock-require/-/mock-require-3.0.3.tgz"
                     "0gnykzqa4hl2fa99assvk5yix0bhsibhm4vhz6h8s7jbqh4vxp11")
        (npm-tarball "ms/-/ms-2.0.0.tgz"
                     "1jrysw9zx14av3jdvc3kywc3xkjqxh748g4s6p1iy634i2mm489n")
        (npm-tarball "ms/-/ms-2.1.3.tgz"
                     "1ii24v83yrryzmj9p369qxmpr53337kkqbdaklpmbv9hwlanwqgn")
        (npm-tarball "muggle-string/-/muggle-string-0.4.1.tgz"
                     "0rw04xcf7fakicpq4nfnm5xbd556mylsp6cr2c41r661gkp1aqv2")
        (npm-tarball "mute-stream/-/mute-stream-3.0.0.tgz"
                     "1sv89cpgn17b65cf4cda9y7s7iwiypiylm96azvsqiip2m29fj09")
        (npm-tarball "nanoid/-/nanoid-3.3.11.tgz"
                     "0nc7hkbfjdbmi3k230g11ypvczfv410mrw27wyk4c6xxww1fh64n")
        (npm-tarball "nanoid/-/nanoid-5.1.7.tgz"
                     "1qwwh9mp0ryslg4383mipndcdvwdqb6pdyw32cbfc6pzyzb85bfd")
        (npm-tarball "negotiator/-/negotiator-0.6.3.tgz"
                     "04sjfqwmsamf29a67zwrjdi3h62avc3y6a9y6a74zsgpl1xnhbli")
        (npm-tarball "negotiator/-/negotiator-0.6.4.tgz"
                     "045jfbblqx9zhv5rd88xsnwbmgkj9li1jflka560syxc6102viwg")
        (npm-tarball "negotiator/-/negotiator-1.0.0.tgz"
                     "015w5p5p4sb02cd9zq20mp7l32jspq206p6d4g355b603ppdz8mm")
        (npm-tarball "neo-async/-/neo-async-2.6.2.tgz"
                     "1x3dxkdflv3ibgab2aj91pkrqpzj62c38dk3x0zvv2qpyh6p18a3")
        (npm-tarball "nise/-/nise-5.1.9.tgz"
                     "09h8281iw67n6sa8ysi6pjrm9zzkxv0816vmmm4j5w3fr83xznzb")
        (npm-tarball "no-case/-/no-case-3.0.4.tgz"
                     "16f6iznap8zhzsj2mlbjfb8dvihgnxnp9wp7wmdy7a9zz3nfqgrh")
        (npm-tarball "node-abi/-/node-abi-4.31.0.tgz"
                     "19byg5zgamyvk395hxvxlbqd8ms78h8v6bixcm8j36gx2whk1wby")
        (npm-tarball "node-addon-api/-/node-addon-api-7.1.1.tgz"
                     "10hzqyn8vxz16gmh4hwdxzw3kn83krkypc0wgb8hqz4pbb8ma15i")
        (npm-tarball "node-api-version/-/node-api-version-0.2.1.tgz"
                     "03ix795pmyjwsvhl443gwcivs7z7pxwgxb6jp3jas2xj0nc1d4y7")
        (npm-tarball "node-fetch/-/node-fetch-2.7.0.tgz"
                     "0aw328j90q3r1d35xgxlz604675hc579h3hlmwpn1nq1kdk4h0x7")
        (npm-tarball "node-gyp/-/node-gyp-11.5.0.tgz"
                     "1nmk6wy1h33v2jpsx9ard6j8ix420fpspq97cr93xgsp7ba0bn6m")
        (npm-tarball "node-int64/-/node-int64-0.4.0.tgz"
                     "0mr21y67mxrzp7ps8w52q8sjp0f4ags8z97f5ig995f86y4n40i5")
        (npm-tarball "node-mock-http/-/node-mock-http-1.0.4.tgz"
                     "12x4zbrvvwq2zgc7hhxp295c9rgd18sjqb8zhxdk78wcj9yxwjrm")
        (npm-tarball "node-releases/-/node-releases-2.0.36.tgz"
                     "1c4flh41sygbsx9xixmiik0yf2ckr19kqb6anq5xyl4ck5n4m665")
        (npm-tarball "node-stdlib-browser/-/node-stdlib-browser-1.3.1.tgz"
                     "0mp0rw6b3y3sg9gsn6vny8q3xma9c96i9yycrqi7646vk9vkz1iy")
        (npm-tarball "nopt/-/nopt-7.2.1.tgz"
                     "0kg4474rl5xw372var4kr6mfzyni1gpfs7bsa7bd19ijvqgcmghs")
        (npm-tarball "nopt/-/nopt-8.1.0.tgz"
                     "19ph23jdxya289vqm94gk0qlcvx9ck76zwbpclwbqh5v63bagav0")
        (npm-tarball "normalize-path/-/normalize-path-2.1.1.tgz"
                     "1d82jyqqyqgk8qkzb4sk7vnz6sgf8xznlm55mazlp43fc6w100cj")
        (npm-tarball "normalize-path/-/normalize-path-3.0.0.tgz"
                     "1zl49w6pdbgi96sgxpzr0gizcj261v6mxv8rx70csmf5ap53r60b")
        (npm-tarball "normalize-url/-/normalize-url-6.1.0.tgz"
                     "03iv7s36r9alrm2krzs05ansrbivd8zgww7f12abdy5sd78b8d4g")
        (npm-tarball "npm-run-path/-/npm-run-path-6.0.0.tgz"
                     "1pwdj6ghn661hpb4clp3bd5p4lmgcwdz484dkyjg4vm4wfikl5l2")
        (npm-tarball "object-assign/-/object-assign-4.1.1.tgz"
                     "1v999sycxcp74j2pikdhyinm2d80p2bsy4nnrrnb59rv4rm74bbq")
        (npm-tarball "object-inspect/-/object-inspect-1.13.4.tgz"
                     "1gwh5vk75w4crskqjsn4ps9z8hqqpjp58d8y82q4b2px79x9c943")
        (npm-tarball "object-is/-/object-is-1.1.6.tgz"
                     "0b7absvz2hh4wcacwv2bxbviyxsq11ri6fkrzas9c0xwvrm1j87d")
        (npm-tarball "object-keys/-/object-keys-1.1.1.tgz"
                     "04pjwxszvk8alk6z5lzk02ba3q56i2g70cs02f57qxhraq2xjy4n")
        (npm-tarball "object.assign/-/object.assign-4.1.7.tgz"
                     "1wzw3gqdzdpvvc4j82xzr9bn5ijldfvkngdc028n3b7p339drr08")
        (npm-tarball "on-finished/-/on-finished-2.4.1.tgz"
                     "02mxvpahgv07xaih7lmpn8wic9v4jph3fir0qpd6qf4w0kql4kgn")
        (npm-tarball "on-headers/-/on-headers-1.1.0.tgz"
                     "0962avqk7n8jxzghmi2q8h3wabr5riwvnlln4bs44m4n95wlf897")
        (npm-tarball "once/-/once-1.4.0.tgz"
                     "1kygzk36kdcfiqz01dhql2dk75rl256m2vlpigv9iikhlc5lclfg")
        (npm-tarball "onetime/-/onetime-5.1.2.tgz"
                     "1kda4mbpk8csafchkakglpfyhsnmdkcl6gv1qi9v5dqwh3mb4ngh")
        (npm-tarball "open/-/open-11.0.0.tgz"
                     "07acva5rzimjgzcsadfm9ihmlz4kf8j5wv6hv5lgvzhjmdjcdm5q")
        (npm-tarball "ora/-/ora-5.4.1.tgz"
                     "1657w05svjq62vlf0dvkhmbrh4hsbyash7504im8fi3apjhckv41")
        (npm-tarball "os-browserify/-/os-browserify-0.3.0.tgz"
                     "0f5pc2ph02ls5xchf1nj0q65m7vkq3lsgpmpbxs5h96qw18nbybx")
        (npm-tarball "p-cancelable/-/p-cancelable-2.1.1.tgz"
                     "1l20j33lw75r4hvrlhahvaj46dwkj8xw45y180i5g3q0qwip1clh")
        (npm-tarball "p-limit/-/p-limit-3.1.0.tgz"
                     "1q69dflz7cr8j18l0va73jyg2nrzd0vq3jhvvica3yna6sbm3rin")
        (npm-tarball "p-locate/-/p-locate-5.0.0.tgz"
                     "1z136h1a3c6a20dzsi5qc24ajk2gs8r59gj1n59sfr89m6019h9f")
        (npm-tarball "p-map/-/p-map-7.0.4.tgz"
                     "1c8n1xnqp0y69g38vnw5ih25cjlk7yhn1mzwhihbwvcss1h9gjqq")
        (npm-tarball "package-json-from-dist/-/package-json-from-dist-1.0.1.tgz"
                     "082fpkvrfsxnsrzdqjf7mzaa8qzavzidavf5n4bhx7b88cz4hp0k")
        (npm-tarball "pako/-/pako-0.2.9.tgz"
                     "17ydqdhy9g76ppkbg0lgkk9837vkpga6gzw8w0m04mfinzqik4sa")
        (npm-tarball "pako/-/pako-1.0.11.tgz"
                     "0h9rmpkzyav4qxpb185z89nrhi17gy8p5mxz1k1l19sj0gf2hh0d")
        (npm-tarball "param-case/-/param-case-3.0.4.tgz"
                     "0z1v8ph0hvhmiwaz080k0dvn3h8zriz6n2c1mi3bvk6sh56fi68s")
        (npm-tarball "parchment/-/parchment-1.1.4.tgz"
                     "07vp71f7ab7k70gfm7pwj6y0k341zc7xwfwh88makp302zcmyji7")
        (npm-tarball "parse-asn1/-/parse-asn1-5.1.9.tgz"
                     "1wd9k0sa82idg2qw169wxh32gszfka7d435sgw353qqc4rwy3dbk")
        (npm-tarball "parse-ms/-/parse-ms-4.0.0.tgz"
                     "0s7vnwlhl2513zvff5f21qml9yz3ds24z6gyz4k9vkbv7wcpxg5b")
        (npm-tarball "parse5/-/parse5-7.3.0.tgz"
                     "0804iy4yfcd3wwlkr0rz8sqawsham82rcaxnf58fia8xyixcl5lk")
        (npm-tarball "parseurl/-/parseurl-1.3.3.tgz"
                     "06h2bx1rilkdir3v9jlg94r1q2fn895s0vxjjs0wx5z027x4pvsn")
        (npm-tarball "pascal-case/-/pascal-case-3.1.2.tgz"
                     "15r35n1jpavykyh5am10ngsjmmssica03w0s4wl989hbzzfmpd8d")
        (npm-tarball "path-browserify/-/path-browserify-1.0.1.tgz"
                     "0ggrp0bhy58j19j1gd87az58w8y3jn0d960pgg8n3jzqqrjnkbbl")
        (npm-tarball "path-exists/-/path-exists-4.0.0.tgz"
                     "0p3pzdvfy2il8p0dvpp1l688in68bh2zzqzcfzvv7s9c634kbdfv")
        (npm-tarball "path-is-absolute/-/path-is-absolute-1.0.1.tgz"
                     "0p7p04xxd8q495qhxmxydyjgzcf762dp1hp2wha2b52n3agp0vbf")
        (npm-tarball "path-key/-/path-key-3.1.1.tgz"
                     "14kvp849wnkg6f3dqgmcb73nnb5k6b3gxf65sgf0x0qlp6n9k2ab")
        (npm-tarball "path-key/-/path-key-4.0.0.tgz"
                     "19s9y2rp8b9wvbccpawvx895d69pam72r1vdvgma51h9k8n9m8mf")
        (npm-tarball "path-parse/-/path-parse-1.0.7.tgz"
                     "18vkai53yyiv1c1rimsh2whiymxnz9xj6a39c6b65097ly61jym0")
        (npm-tarball "path-scurry/-/path-scurry-1.11.1.tgz"
                     "029l4iwj6k606dm55hp9d63bxjwswcaskhkgyyb7hc4bs0f3ikpx")
        (npm-tarball "path-scurry/-/path-scurry-2.0.2.tgz"
                     "1h9yq8i7j1hl3vixpqnx23hwfl10n0ri26w7npy2h360n7df78yy")
        (npm-tarball "path-to-regexp/-/path-to-regexp-6.3.0.tgz"
                     "1rj24zc23lw6avfahfhnlbv49y1w0kr1845d7n6jfh8376224c6s")
        (npm-tarball "path-to-regexp/-/path-to-regexp-8.3.0.tgz"
                     "0igs3l0g1yjnvk3hrk1g86m46nm7dydvcf62kvhvdhapdi58rjl0")
        (npm-tarball "pathe/-/pathe-2.0.3.tgz"
                     "0dnzjq3529b584wj6rich8p0c16s0ydlbn7miw88lzxvbny76fvf")
        (npm-tarball "pathval/-/pathval-2.0.1.tgz"
                     "0z1spyv0r0jkzflhr9hk9nx834xnhpvka7wxwni06iqhg8p9w25g")
        (npm-tarball "pbkdf2/-/pbkdf2-3.1.5.tgz"
                     "0sfnx75427z7sh0p7vlav4zidzp7birm7jsbs59misfjbf4ifcgn")
        (npm-tarball "pe-library/-/pe-library-0.4.1.tgz"
                     "0yrxpi2pga6g4nawmyy8jkg0wq9j2nr2z7qxf1p5vbik921yx3zm")
        (npm-tarball "pend/-/pend-1.2.0.tgz"
                     "0zvd8cli24vpvgsf9ldmm5ibivmx02njp2d9a85p3px94ndjfbx1")
        (npm-tarball "perfect-debounce/-/perfect-debounce-1.0.0.tgz"
                     "1bmp0i4qvix8yyrfjki9a5v9kc120f79zfb86ixf3vbk4dan25nd")
        (npm-tarball "picocolors/-/picocolors-1.1.1.tgz"
                     "1nc2z3w16wpz2840srcwyxd747khwfvh66yigyrpwywn0wldpbnk")
        (npm-tarball "picomatch/-/picomatch-4.0.4.tgz"
                     "072pg3ji6ib0ns6jv3ypink59pmfj8432fj82yhxk3jmcsv5lnsi")
        (npm-tarball "pkg-dir/-/pkg-dir-5.0.0.tgz"
                     "04n9i5w3dabb73yxy1g3qgvj6v1apr4aimm35pxslx9j30hpc6y3")
        (npm-tarball "pkg-types/-/pkg-types-1.3.1.tgz"
                     "1649va7xklpz1y8izwm8wkj3kshw8wfhyxyphpigl2pfn6f2wbnk")
        (npm-tarball "pkijs/-/pkijs-3.4.0.tgz"
                     "14wpiqcsg7qnvy532qpgggq28mz6dzwvlj520bvrgv74zrvwrwav")
        (npm-tarball "plist/-/plist-3.1.0.tgz"
                     "196zs6wqjpmg1dcw7a93wgqs5dl8ay0i78bggxhlpc539927v5za")
        (npm-tarball "pluralize/-/pluralize-8.0.0.tgz"
                     "15dnymzb5qiqywc6k0dhfhjpgsv8799n5qb04y6w2cwa9skn8i4q")
        (npm-tarball "possible-typed-array-names/-/possible-typed-array-names-1.1.0.tgz"
                     "1iz3wdm7qsrp0m8hq52c2gj808r98d422iwj0hf1hbwf3chr35y2")
        (npm-tarball "postcss-value-parser/-/postcss-value-parser-4.2.0.tgz"
                     "19whda1if07mb56pyqw7y750xclqnaqld82qn92a6rjvz4n3gr9x")
        (npm-tarball "postcss/-/postcss-8.5.8.tgz"
                     "0w5vwgc9b1snnxmm85fi7s8ja1kl2gw3qhjd5244l5q84lq7wbbk")
        (npm-tarball "postject/-/postject-1.0.0-alpha.6.tgz"
                     "14kxgr9zvkp4rkazciya1rv75yps1a3hqddkgypxsjbxx19pni6i")
        (npm-tarball "powershell-utils/-/powershell-utils-0.1.0.tgz"
                     "0aqrjbd5ib1h3iv9lqmkcc50cfl3303b71l152nxcwr17qvypfdb")
        (npm-tarball "pretty-ms/-/pretty-ms-9.3.0.tgz"
                     "0275gwzr73psg918vrbcqmai400qnp2dm7ay9a6zylzw43fg5206")
        (npm-tarball "proc-log/-/proc-log-5.0.0.tgz"
                     "1ml77wixzmrpshkkihi2nv84n5g17sa67zhwjjx8xlqp5bdwzy4b")
        (npm-tarball "process-nextick-args/-/process-nextick-args-2.0.1.tgz"
                     "16w8m2ycy5s4ykgdfg97qxa67gfvkh6x3vdwfsncafyj4p3zhns2")
        (npm-tarball "process/-/process-0.11.10.tgz"
                     "1fz6fjkaldphhj1vphhk00d35k2gkw7x8c6n58amdc4w7jdmc43w")
        (npm-tarball "progress/-/progress-2.0.3.tgz"
                     "191ax3hag867ggjsn6wh1b00bp5iippxsml7fyxf7h7nizhna63h")
        (npm-tarball "promise-retry/-/promise-retry-2.0.1.tgz"
                     "1k2mdc2jbw2h3ykxcgvh2wv20gdb6m1siacllr7dy2x4rlk3g5jq")
        (npm-tarball "proper-lockfile/-/proper-lockfile-4.1.2.tgz"
                     "0s49g8x645nacdxwmyy0w4rgl08ba5lv73wjpgnwpbkwlm5r2y7x")
        (npm-tarball "proto-list/-/proto-list-1.2.4.tgz"
                     "1zlmz3s0a170rxb3djr4v2qc03n50jmwrhacf722z7zasslx52nw")
        (npm-tarball "proxy-addr/-/proxy-addr-2.0.7.tgz"
                     "1na6xrmlga7qjd55gfhnp7m8qg43nynzg5ds54s76kkd9zrvdld0")
        (npm-tarball "public-encrypt/-/public-encrypt-4.0.3.tgz"
                     "0jq1q88z1g159pdj5c3s398g3i9sksphc1xia4s69gx76jhfq3kz")
        (npm-tarball "pump/-/pump-3.0.4.tgz"
                     "0dlv9kb9py5sgiv935266khkb284iqfyhcqbpgd5q0rh9kycfn1w")
        (npm-tarball "punycode/-/punycode-1.4.1.tgz"
                     "12gdim25jn0g82kqql0qb44kjf8gbwzhcy8wf53vq56ad5rwlas5")
        (npm-tarball "pvtsutils/-/pvtsutils-1.3.6.tgz"
                     "0kc39klf2m0kl86497dbh2kr7a2ikc6hx86lhshn9y6javph6kfw")
        (npm-tarball "pvutils/-/pvutils-1.1.5.tgz"
                     "1y5i60cdb4rw15y6bxd6j6zkjl2wcib2mrrd2d0lgkhspw21zf3d")
        (npm-tarball "qs/-/qs-6.15.0.tgz"
                     "1gym6aw1dhcpmf90lsnbmbym513p85sbpms5gfpcb610lmjiakvc")
        (npm-tarball "quasar/-/quasar-2.19.1.tgz"
                     "08qdpm4b8yw6zbn28j91iirfgxz2gx8knmmqhjdzhd5frggrkj45")
        (npm-tarball "querystring-es3/-/querystring-es3-0.2.1.tgz"
                     "0gi8dwjxni9waygxwdp6jq2gv94ad1vsmhfn4aq7md477bz8k8z5")
        (npm-tarball "quick-lru/-/quick-lru-5.1.1.tgz"
                     "1prmggnyx8kw2f4fxbqpaj9hnlpkxaydmkgrvi7qv8h9la25i0xr")
        (npm-tarball "quicktype-core/-/quicktype-core-23.2.6.tgz"
                     "0424zhl75ynhmsgi4m6lizlh18ry57s255v6n7b8vlv4cbk4wirm")
        (npm-tarball "quill-delta/-/quill-delta-3.6.3.tgz"
                     "0pigchz6lbwjpka4mbv0l2y89n6apnys8vgp1anv1iilkq72pxbn")
        (npm-tarball "quill-delta/-/quill-delta-5.1.0.tgz"
                     "12b2pawdjy9qr7275h9x76zdav6qzlabqyn1rpgg55s2ylwl7ily")
        (npm-tarball "quill/-/quill-1.3.7.tgz"
                     "0brprrh9if9wq9g3ps8ivdajq8r51zhp04630mvqrhfnkb59shd7")
        (npm-tarball "radix3/-/radix3-1.1.2.tgz"
                     "014ii4q8dpbxx801d74zmwvskl02n3mkc0iad373di07mqpj4lha")
        (npm-tarball "randombytes/-/randombytes-2.1.0.tgz"
                     "1amws6pwpznpl6d58rsi3aa2cl779gkb1jysscm925r8agkd79mq")
        (npm-tarball "randomfill/-/randomfill-1.0.4.tgz"
                     "19jgfpgf0c0smavmwljk525drngzw0162q33jl9jwmvaazn2y31v")
        (npm-tarball "range-parser/-/range-parser-1.2.1.tgz"
                     "09prs852snwqr9cfcrybm7ysl0z1wka9dh4dwc4v1415cvi6cllh")
        (npm-tarball "raw-body/-/raw-body-3.0.2.tgz"
                     "1nqrhjp2v55z7rd13f1qlgnk6vgc4hmd9c8awnxmipina012mpk6")
        (npm-tarball "read-binary-file-arch/-/read-binary-file-arch-1.0.6.tgz"
                     "1dz61k816gkpsqv4316jxdn08h0r6k68vjk5qshxq35z3vxxa02g")
        (npm-tarball "readable-stream/-/readable-stream-2.3.8.tgz"
                     "0cm5g4a5mfqb5im98mzv5y3dpv377bws6wlgpv5wk2pn90wn2j0n")
        (npm-tarball "readable-stream/-/readable-stream-3.6.2.tgz"
                     "0pdb0mrh95ks672ikgj8frx9nh078bfyngknj70ak2iibv06dn7d")
        (npm-tarball "readable-stream/-/readable-stream-4.5.2.tgz"
                     "1q17xzxddii36nl85d6zhl3hgr6025mlxpvvm5hhhqfn1kplwcxw")
        (npm-tarball "readable-stream/-/readable-stream-4.7.0.tgz"
                     "1zg5vp8c6ncrm6sy3x6jijzjizmcgca55n6s2hbvj9qrnyff95q9")
        (npm-tarball "readdir-glob/-/readdir-glob-1.1.3.tgz"
                     "0ds4va2h9ir4bcy9i2ka414vzv73lp0mrwj20d66z5bnqcwvsswv")
        (npm-tarball "readdirp/-/readdirp-4.1.2.tgz"
                     "0njzcnyjv31k0lw1rswaay334iyck4wvx6wwjdmzxbhlcfxa4vkn")
        (npm-tarball "readdirp/-/readdirp-5.0.0.tgz"
                     "01q4n1i7m5k7zvk1chxca088814nyvcd28rb8s64pnwgpzbdkv01")
        (npm-tarball "reflect-metadata/-/reflect-metadata-0.2.2.tgz"
                     "13zi3mz2pgs8c5bd6bmi52cr6c3xcx73rylvh943c8h1f2kjxmfa")
        (npm-tarball "regexp.prototype.flags/-/regexp.prototype.flags-1.5.4.tgz"
                     "17qc391zhwyjf9qdfgd6cxmc45bz3rp3zai14x9lqh999janwcz3")
        (npm-tarball "relateurl/-/relateurl-0.2.7.tgz"
                     "0r1d6p5gdah2x30kaaf0vy4bpf81wfxcy97vvg7f2k99qj81ja38")
        (npm-tarball "remove-trailing-separator/-/remove-trailing-separator-1.1.0.tgz"
                     "08b3msz9s5kw1alivgn9saaz6w04grjqppkdk3qbr7blk38l04sf")
        (npm-tarball "require-directory/-/require-directory-2.1.1.tgz"
                     "1j46ydacaai73mx5krskl0k78r32lnjx94l79bz860rn8h4fwfvh")
        (npm-tarball "require-from-string/-/require-from-string-2.0.2.tgz"
                     "10ldp2bzb86czf47kmvirn9x2976yh6g0my7l1spg3whcm4llsfb")
        (npm-tarball "resedit/-/resedit-1.7.2.tgz"
                     "1kdidj5wpbh8d164y2ckmjaggidsvpnz4la62q9vhjfhn722nn6v")
        (npm-tarball "resolve-alpn/-/resolve-alpn-1.2.1.tgz"
                     "0853fjjwl8as4px6mh6fcs59mnk4l5f4g7yl7pig0m9s72w4z5zx")
        (npm-tarball "resolve-pkg-maps/-/resolve-pkg-maps-1.0.0.tgz"
                     "0xnzn1fl08qp7s8n886hd7zrbd3pjnz2jw86cvjdc7ab0nvvsz2a")
        (npm-tarball "resolve/-/resolve-1.22.11.tgz"
                     "1z12d7j010zhhi3i8y0596nzp1c6zj7gfcvwvszx9qr49wmrrcjy")
        (npm-tarball "responselike/-/responselike-2.0.1.tgz"
                     "1xaszdarkass77bwzijlnrqfsh05rkvgf2b6909hcf0pn31s8bvy")
        (npm-tarball "restore-cursor/-/restore-cursor-3.1.0.tgz"
                     "0agcwdj60w84fji19wc2a6fj9b9apsf56yx3awlb0k0zndmp2j09")
        (npm-tarball "retry/-/retry-0.12.0.tgz"
                     "0a5l61f1aqn124j25m2q6m0j60mv7d9h74a8gfqnmp5ajz8wcqfz")
        (npm-tarball "rfdc/-/rfdc-1.4.1.tgz"
                     "0sjn3nwwlyg2m8354r7lzl0ip8wvhcsxlwm4vy6ijywj3n3z36jm")
        (npm-tarball "rimraf/-/rimraf-2.6.3.tgz"
                     "0zkzyrndihic25mizl3hhqw3y2ah36hq5kr4rqcwy56jpp56zdcc")
        (npm-tarball "rimraf/-/rimraf-2.7.1.tgz"
                     "0g1grvjh2bpjpalqszzprh6hvnlvab9pmqa137yslysbv6g4x7h0")
        (npm-tarball "rimraf/-/rimraf-3.0.2.tgz"
                     "0lkzjyxjij6ssh5h2l3ncp0zx00ylzhww766dq2vf1s7v07w4xjq")
        (npm-tarball "ripemd160/-/ripemd160-2.0.3.tgz"
                     "090zc1hhr7ij1lgy5x83l4d6r5azyvcxd1m89mhx525n40rbnnig")
        (npm-tarball "roarr/-/roarr-2.15.4.tgz"
                     "1n4lyd5s9j07aj00hy2kpgkilk1f8mrqqhmrawqnx6j4aszyymia")
        (npm-tarball "rolldown/-/rolldown-1.0.0-rc.11.tgz"
                     "1za12v4vwn6fg0q3ddgbsvhp4bn2nngb9wd301fa6w4jmyjpc4gg")
        (npm-tarball "rollup-plugin-visualizer/-/rollup-plugin-visualizer-7.0.1.tgz"
                     "0bnn8ahb21ynn5d9gnp70z4gls7wjmgjsz8glrmd47gh80qr6psx")
        (npm-tarball "rollup/-/rollup-4.60.0.tgz"
                     "15726x9b2bymxyl6jkkhl3531avimpfd278jazn3nzbnl026w3ka")
        (npm-tarball "router/-/router-2.2.0.tgz"
                     "0qclnvx6zzlrqj03wz8lyh9rzwickiz8c7czm3vig5csncvsyi5i")
        (npm-tarball "run-applescript/-/run-applescript-7.1.0.tgz"
                     "17ccrallz3df13sh6pdkpfcni3i3gharlzh236qxd85a2xqwx6nj")
        (npm-tarball "run-async/-/run-async-4.0.6.tgz"
                     "0lc1an955w44n670nzq3i5j0w03s7xhz4w1xx0hl2jvfj9i2d4v7")
        (npm-tarball "rxjs/-/rxjs-7.8.2.tgz"
                     "10mcdzpzb20bqx4g89ikvjihjgb62dgjr89ysmxzsvvjv7zzh4i3")
        (npm-tarball "safe-buffer/-/safe-buffer-5.1.2.tgz"
                     "08ma0a2a9j537bxl7qd2dn6sjcdhrclpdbslr19bkbyc1z30d4p0")
        (npm-tarball "safe-buffer/-/safe-buffer-5.2.1.tgz"
                     "1s5kvjpwqsc682zcy71h9c6pxla21sysfwj270x6jjkca421h62x")
        (npm-tarball "safe-regex-test/-/safe-regex-test-1.1.0.tgz"
                     "0bpiiiylzwi6npmli5acycw9wd0akip8lkv6mfnhdvs9hl7d4ap9")
        (npm-tarball "safer-buffer/-/safer-buffer-2.1.2.tgz"
                     "1cx383s7vchfac8jlg3mnb820hkgcvhcpfn9w4f0g61vmrjjz0bq")
        (npm-tarball "sanitize-filename/-/sanitize-filename-1.6.4.tgz"
                     "1spkmc7s99fixfsn3dzix9m07a6wd0zbsmz463qalhv2b8h6x4s2")
        (npm-tarball "sass-embedded-linux-musl-x64/-/sass-embedded-linux-musl-x64-1.98.0.tgz"
                     "0r3ky8q064bi0zrzvb9gnnbi260pnc58ic389vdkzz3hvr7jpw6p")
        (npm-tarball "sass-embedded-linux-x64/-/sass-embedded-linux-x64-1.98.0.tgz"
                     "1c03fpapcqnswvp1001ww0sfpd55479jc9fq63dvv6crycvb6gax")
        (npm-tarball "sass-embedded/-/sass-embedded-1.98.0.tgz"
                     "0agivimdhp1xqz7j3ahp5zhkg7a56nbv04l4p9sldvg5gn7bnak6")
        (npm-tarball "sass-loader/-/sass-loader-16.0.7.tgz"
                     "1dhy72bwbjy5z26z73vxfd67yqh1hryrb0prg252kvmdnxbnzy5s")
        (npm-tarball "sass/-/sass-1.98.0.tgz"
                     "1mid0xsrcswcbr2p8jlpwzd2wx4y3pgx6myfghplzd863d77a50b")
        (npm-tarball "sax/-/sax-1.1.4.tgz"
                     "07vl4693symckpgpnbydvgwvm7c3yw3nyl3zz9vc5azalmb47b2c")
        (npm-tarball "sax/-/sax-1.6.0.tgz"
                     "1x4ryrxdafsjvzyiqd6avzqqy44sgf812i415n6g2bb40z9aq96l")
        (npm-tarball "selfsigned/-/selfsigned-5.5.0.tgz"
                     "1v9hkjl8dd2kcgxzrdl571n4z6xjhw2s2p9xg04zdz4l43rxaz05")
        (npm-tarball "semver-compare/-/semver-compare-1.0.0.tgz"
                     "101wry6pwhbl7h3icx4vic5x87hhsgim55z01ylq3nm736bnkwg7")
        (npm-tarball "semver/-/semver-5.7.2.tgz"
                     "1yamwq6fygzmjv84rl0zwadr91xchml9dplv6k7xv628pi6kfj75")
        (npm-tarball "semver/-/semver-6.3.1.tgz"
                     "0c0jxgjhgpxx7hdbmwghndq2mdpg58295mwv1b8cp6g070m096rw")
        (npm-tarball "semver/-/semver-7.7.4.tgz"
                     "1321x4pnc5cvfxkmlinc013kn43rn0yxrf69j1khwc7yik87l9h9")
        (npm-tarball "semver/-/semver-7.8.2.tgz"
                     "143lgq3w4qwc0m3aqb1q2py9i314ckig7y588hs1fdmfc3xai1k5")
        (npm-tarball "send/-/send-1.2.1.tgz"
                     "0wn46l21fl21yf5abnx3yr6fr2kq4cxm7ggf5g5xs8yx2srly9gs")
        (npm-tarball "serialize-error/-/serialize-error-7.0.1.tgz"
                     "0q657dq63b2839q2m4bn5bvvjdfn8djrf48n0f7r9av051h1s796")
        (npm-tarball "serialize-javascript/-/serialize-javascript-3.1.0.tgz"
                     "0ndaydacz57zm06i8f58yl5g6fid4a0zh0y6psigqqrixk7zgh78")
        (npm-tarball "serialize-javascript/-/serialize-javascript-7.0.5.tgz"
                     "0cxdksa2394cjzjyshhvrfbkhc5glmgdi2irxijdqxd3kj3594ba")
        (npm-tarball "serve-static/-/serve-static-2.2.1.tgz"
                     "0hszcbfcncifwgxk060jy1andx4b7pzjbvig40cfnwlknlmzgm1n")
        (npm-tarball "set-function-length/-/set-function-length-1.2.2.tgz"
                     "0jibjpyi630gp59w40fjhnarmmhjaa8n8x0kw8zpll53vxqdyfd3")
        (npm-tarball "set-function-name/-/set-function-name-2.0.2.tgz"
                     "1wry0dvq3b7x3zfj5369w9cahjngagw6v975xrp2wlz0jxxffh4j")
        (npm-tarball "setimmediate/-/setimmediate-1.0.5.tgz"
                     "17icj9sgsg9fcyclds1a8mlgmspza3fa6sidq11fsr43d4igrfaw")
        (npm-tarball "setprototypeof/-/setprototypeof-1.2.0.tgz"
                     "1qnzx8bl8h1vga28pf59mjd52wvh1hf3ma18d4zpwmijlrpcqfy8")
        (npm-tarball "sha.js/-/sha.js-2.4.12.tgz"
                     "1h4xxrhndrbns05ivlzayn9i4idwwcq80f07958v68p8hi2y1hf8")
        (npm-tarball "shallow-clone/-/shallow-clone-3.0.1.tgz"
                     "0cxafqsg8mbvs4cc7z3xjpnmdpx8svmldwcg1w9r73fyi8hjvrpq")
        (npm-tarball "shebang-command/-/shebang-command-2.0.0.tgz"
                     "0vjmdpwcz23glkhlmxny8hc3x01zyr6hwf4qb3grq7m532ysbjws")
        (npm-tarball "shebang-regex/-/shebang-regex-3.0.0.tgz"
                     "13wmb23w5srjpn9xx1c85yk5jbc5z9ypg0iz33h6nv5jdnmapnzy")
        (npm-tarball "shell-quote/-/shell-quote-1.8.3.tgz"
                     "1h92gr88jggrii0xg6q7fd5y0dqmjm82wan7sqiji3mg9cshnr6z")
        (npm-tarball "side-channel-list/-/side-channel-list-1.0.0.tgz"
                     "1k8wgnr29504nxwmh9p5d88462zdvc2y9nswjjlsrj7bqaq4w1sq")
        (npm-tarball "side-channel-map/-/side-channel-map-1.0.1.tgz"
                     "1mhnf4m2zdv1ikvjk74v6d7fhr2bzn41a6w95nbcq2rh45j6n99v")
        (npm-tarball "side-channel-weakmap/-/side-channel-weakmap-1.0.2.tgz"
                     "0vnhs2whvv59nkqdsfpmd1fwrcjzh2ka5z8giy68kbg7qpq58aiv")
        (npm-tarball "side-channel/-/side-channel-1.1.0.tgz"
                     "11d40rvhvkj4r1dis1vmzi0gc6qnvw90jkc2ppz2w90bk5xyg4w4")
        (npm-tarball "siginfo/-/siginfo-2.0.0.tgz"
                     "06vhqyr028bznlnfi0f4inr0526mk10ns5ya9ab4jh2iqi9xh3x2")
        (npm-tarball "signal-exit/-/signal-exit-3.0.7.tgz"
                     "1a10ixkiak24yy6s7p9m7c6v9jkz2fm7wxgc2l3614dbdbx275j3")
        (npm-tarball "signal-exit/-/signal-exit-4.1.0.tgz"
                     "15dpm2y84hd7ybqy89raj6xza56dfj92i1vkad0sdxpc26l5hfwx")
        (npm-tarball "simple-update-notifier/-/simple-update-notifier-2.0.0.tgz"
                     "1wig8ccrk6swz38hnliqxqsivgc9axwby98gq30lzgyd0m97pkpf")
        (npm-tarball "sinon/-/sinon-11.1.2.tgz"
                     "0ijnv9w2zvr54hv1rw93fzi4fdmzvqssgx9ddwnck82b5c3lm92h")
        (npm-tarball "smart-buffer/-/smart-buffer-4.2.0.tgz"
                     "18ahcjprcl5mr719dxpzh7kq1lylnwzf7j3bmi3vkgnirgj1b61x")
        (npm-tarball "socket.io-adapter/-/socket.io-adapter-2.5.6.tgz"
                     "1qcdbdpzg2f8zsvfr6bj29ihqvpd6wlp7cz8ixy0bcsylxk4xih5")
        (npm-tarball "socket.io-client/-/socket.io-client-4.8.3.tgz"
                     "0a85f90zrrn1pg8hxbkmvq58a6jbrzi0ksdkvn6pc197nxvbjgal")
        (npm-tarball "socket.io-parser/-/socket.io-parser-4.2.6.tgz"
                     "1jjqqdypcg19cfhd3qvmfcgr2jb6fap1rinij6wfaq9s3748rar3")
        (npm-tarball "socket.io/-/socket.io-4.8.3.tgz"
                     "1dsgr85sli6fzprn433r1kfkn2jbiy3libjbza6fx5zvck7ybjhi")
        (npm-tarball "socks-proxy-agent/-/socks-proxy-agent-8.0.5.tgz"
                     "1xn1zw629fi49gyjnq4ymncv6zd0mgpjh28rmxmyp10z628syffl")
        (npm-tarball "socks/-/socks-2.8.7.tgz"
                     "0m3fvf2hvmff0n2vxf72yrp6jav38y0zphsf94qd8zry2dalbzxg")
        (npm-tarball "sortablejs/-/sortablejs-1.14.0.tgz"
                     "1zai1xc8xifpzskm508n3sgjy8nwb7431fgsq0plwqxx4rjxqr5r")
        (npm-tarball "source-map-js/-/source-map-js-1.2.1.tgz"
                     "0ls8kncpxm2wxd4da6b1jrx1hyajjlx8rjyq34ra91x4zkwsc9pi")
        (npm-tarball "source-map-support/-/source-map-support-0.5.21.tgz"
                     "0dpnahsipxckan03b5w5qrmlibkz8amh7k6gj77zs9387vph96sx")
        (npm-tarball "source-map/-/source-map-0.6.1.tgz"
                     "11ib173i7xf5sd85da9jfrcbzygr48pppz5csl15hnpz2w6s3g5x")
        (npm-tarball "source-map/-/source-map-0.7.6.tgz"
                     "0sy1xg5n77wcrf9sqmssilr90gajah78brckizvaz80646vvwim8")
        (npm-tarball "speakingurl/-/speakingurl-14.0.1.tgz"
                     "0wqrdi1524k3c81mv8zpsmis89w0gy0lva6v2pnb0c7cnh4nlbz8")
        (npm-tarball "sprintf-js/-/sprintf-js-1.1.3.tgz"
                     "1dmfvr48ls8m3yjlhrn4f55jsjnv36p3ikzmamq9hbnxij93g1cs")
        (npm-tarball "ssri/-/ssri-12.0.0.tgz"
                     "19xdnbgh8qyxvsfg9jdh5gk0baym555xz2xfjhbyhbyvpbpjfy19")
        (npm-tarball "stack-trace/-/stack-trace-1.0.0-pre2.tgz"
                     "08mj59733dgm46dq0a643ydxs9kkj1zlvlifizyrpr999hiyrl5y")
        (npm-tarball "stackback/-/stackback-0.0.2.tgz"
                     "0n2qll6342m6219skx7cjmc6rpd747n4idj6sj779yfcs613qriy")
        (npm-tarball "stat-mode/-/stat-mode-1.0.0.tgz"
                     "1hqpcydwfvxc5b26jpnx2fc9bxzxxjk8rjbfnycmd0bv2gmw9z44")
        (npm-tarball "statuses/-/statuses-2.0.2.tgz"
                     "1q4zjhjprvhdjc32px6b4b0i3ffn1mbqygp7yilbb204f4j0m06a")
        (npm-tarball "std-env/-/std-env-3.10.0.tgz"
                     "1lmqdsjbs0kd534fcxc0fcxmry8bnna2zqwl42vj8rjmx6pgxzha")
        (npm-tarball "stream-browserify/-/stream-browserify-3.0.0.tgz"
                     "1krkljlpwvy6pghvrlf1c84b0incvflgh4624g7n32fkzz0a8vrp")
        (npm-tarball "stream-http/-/stream-http-3.2.0.tgz"
                     "0g5hrd26lv80h9c5gd342i35z7qkikpllc8zaclp8kicci529gc2")
        (npm-tarball "streamx/-/streamx-2.25.0.tgz"
                     "0gaj84b2m3sq25qg94c2dahgbgxw9bgvypvfv61iiky3xs3x95ny")
        (npm-tarball "string-width/-/string-width-4.2.3.tgz"
                     "0d19spdisrqxd6311fc7z1yg34ww6rwh1zxdk6pnk03fnaqlzfxd")
        (npm-tarball "string-width/-/string-width-5.1.2.tgz"
                     "0dzl2ih475g7rdyvxfcmmbfhiz29yx5zg4nfbn1a12nbpnhi22a1")
        (npm-tarball "string-width/-/string-width-7.2.0.tgz"
                     "1wzipf9yyzrklrv5g1f7h46p6j8z31nkx5g2dycgdpnak0d9141y")
        (npm-tarball "string_decoder/-/string_decoder-1.1.1.tgz"
                     "0fln2r91b8gj845j7jl76fvsp7nij13fyzvz82985yh88m1n50mg")
        (npm-tarball "string_decoder/-/string_decoder-1.3.0.tgz"
                     "1bdkjw2kn1h4lrmqqfdwajsg9yivn92swwc3aciy8i83jh06j0vx")
        (npm-tarball "strip-ansi/-/strip-ansi-6.0.1.tgz"
                     "1jh81jj6cn1lli1c7m6xi0ynra9zdghb1g63v1nib7zlpz87bnwv")
        (npm-tarball "strip-ansi/-/strip-ansi-7.2.0.tgz"
                     "0gsl102g2x95xl1vyp2s3z9wb8ak9blc9frsfwrfy8jhdbl1v81g")
        (npm-tarball "strip-final-newline/-/strip-final-newline-4.0.0.tgz"
                     "17lsqdpy1wgnxm2g5ln2a86zps09a6xadqxq56rqsmgl373zcjax")
        (npm-tarball "strip-literal/-/strip-literal-3.1.0.tgz"
                     "1c3zicm6kb3wm50xqbbadfldqwc4b6gkbjjp115iw98r6jawhrb9")
        (npm-tarball "sumchecker/-/sumchecker-3.0.1.tgz"
                     "026xzxspqlk8zia7x0qalpmz9mxg5w3wvcq3m0rik9rkbc0g6mk7")
        (npm-tarball "superjson/-/superjson-2.2.6.tgz"
                     "16182f8zll36igddh47fw7d6zv5g92mfl1n1apvc4yrzw9jxggmj")
        (npm-tarball "supports-color/-/supports-color-7.2.0.tgz"
                     "0jjyglzdzscmhgidn43zc218q5jf9h03hmaaq9h4wqil2vywlspi")
        (npm-tarball "supports-color/-/supports-color-8.1.1.tgz"
                     "1c2g6va5j9qvjk2j36hi6vlzvqvdq2cm8aziz4r9j40yh2sxjsga")
        (npm-tarball "supports-preserve-symlinks-flag/-/supports-preserve-symlinks-flag-1.0.0.tgz"
                     "1ygp0kk7p6df5p6p2q1csdshilklhfbh49g7h90m6i2kmxh13nlp")
        (npm-tarball "sync-child-process/-/sync-child-process-1.0.2.tgz"
                     "1blwymwys8j5v9z170mxvvq2xf521vzwp3kbfsfc1qsxag9q2hii")
        (npm-tarball "sync-message-port/-/sync-message-port-1.2.0.tgz"
                     "1xq3vv5d6i9sj7kz38m06sfjwp0vqx79mp6llv53n0k1fssgw9xn")
        (npm-tarball "tagged-tag/-/tagged-tag-1.0.0.tgz"
                     "0rpb0k2vnav3ad9d42899ayb8hbjrxk59a2j6yfx05xwc2lh59kx")
        (npm-tarball "tar-stream/-/tar-stream-3.1.8.tgz"
                     "02gcn6kw94mcn5pqqv0c95lmqrn6w21lanvamdqcnhn1g94c0ahi")
        (npm-tarball "tar/-/tar-6.2.1.tgz"
                     "1rq6xlbdinwxr7nw054l65vji57d28hx7y3i7bbrcsar2ahigl6n")
        (npm-tarball "tar/-/tar-7.5.16.tgz"
                     "02bsb47k1wc426fdj9vnifdwbys0h0315skqrs2c0aidpjlqixxz")
        (npm-tarball "teex/-/teex-1.0.1.tgz"
                     "1s7ygzc588158jhgpnvbxwk89s0ps0sjpn6335pxykznxsmsxgwg")
        (npm-tarball "temp-file/-/temp-file-3.4.0.tgz"
                     "1pc096ghsr4f2p3cpys6rb33mx7pv6h0xgxapfb8zmlpp53aihw4")
        (npm-tarball "temp/-/temp-0.9.4.tgz"
                     "08pwh41s9kax4hjcmdb7j06hbas48h2k8j8y9qkgigrvnwg9rm6z")
        (npm-tarball "terser/-/terser-5.46.1.tgz"
                     "1y9df9c33w1fy7pgnswqsa40z5ikg4q54j1ly2icm9nmslsqmgbx")
        (npm-tarball "text-decoder/-/text-decoder-1.2.7.tgz"
                     "1rhjcsgz1290hql5sa66xn2j0k6mfsg924byj601czv9s4k1qzxr")
        (npm-tarball "timers-browserify/-/timers-browserify-2.0.12.tgz"
                     "0chlg4h6s6hj6kgrsvwz7l2srx9p5ghld8x22mamcv7kn4lapmai")
        (npm-tarball "tiny-async-pool/-/tiny-async-pool-1.3.0.tgz"
                     "02vb3nwfl17gg6nfh1qcmarb0irc1qf6pljiqc2mrsqkipcf2amk")
        (npm-tarball "tiny-inflate/-/tiny-inflate-1.0.3.tgz"
                     "0klgdanxyf1rl8gs1ckpw9z41aww4a0n8gh4mypgzr94jhrjp4vk")
        (npm-tarball "tiny-typed-emitter/-/tiny-typed-emitter-2.1.0.tgz"
                     "0fmbwq3qbk29nkm87hx1hnfsxirr0mysrl1i226k12j1ijzwi1rr")
        (npm-tarball "tinybench/-/tinybench-2.9.0.tgz"
                     "0f9fb0840qfhz6kbwpv12an1ia6qwbx7w7ml1xkmjqrnq99yjf1s")
        (npm-tarball "tinyexec/-/tinyexec-0.3.2.tgz"
                     "1s7xjg30d8zn3svpilm3mjwrqkknbvd5nw55k327a8wkmx24295i")
        (npm-tarball "tinyglobby/-/tinyglobby-0.2.15.tgz"
                     "1p993j64mlwzk3c9c5vx2v4ja5x4yl4cszqhabczng9pzppzb4dr")
        (npm-tarball "tinypool/-/tinypool-1.1.1.tgz"
                     "02mnxjf3fazy2ad4jivj3ca265sxghg6nv33pik7ap8scj3yd1d5")
        (npm-tarball "tinyrainbow/-/tinyrainbow-2.0.0.tgz"
                     "0xdz1nzilgkakk3f4kcj8kiwpj2q6mczh0r089ixby4lshf100an")
        (npm-tarball "tinyspy/-/tinyspy-4.0.4.tgz"
                     "1dbffq4bvjv763sayrm6ddmpgz9p1xjal864qga07rfjnkcmz4ds")
        (npm-tarball "tmp-promise/-/tmp-promise-3.0.3.tgz"
                     "1nf9pds0x20r9w4gkgx46j5axigbwn06nbrvi56s8i0y2hjlr24x")
        (npm-tarball "tmp/-/tmp-0.2.5.tgz"
                     "1j6dw6dn296xs61cvvxpxf5pi8m17ava0xvsfp4xx2x20q87b5cy")
        (npm-tarball "to-buffer/-/to-buffer-1.2.2.tgz"
                     "0g77pd0s9jf3rr8hfspxipbhwd7yvql2wx6fyvamma9xarym8zzv")
        (npm-tarball "toidentifier/-/toidentifier-1.0.1.tgz"
                     "021fp42m51qbqbqabwhxky8bkfkkwza65lqiz7d2gqwd91vwqvqq")
        (npm-tarball "tr46/-/tr46-0.0.3.tgz"
                     "02ia19bsjr545jlkgv35psmzzr5avic96zxw3dam78yf6bmy2jhn")
        (npm-tarball "traverse/-/traverse-0.3.9.tgz"
                     "0hh92qg7n1byqifbk31ly108fdlw26f8nrr94szqhy7wmnqzc4vq")
        (npm-tarball "trim-newlines/-/trim-newlines-4.1.1.tgz"
                     "1xp3p4ssy1na08krxblc1j3pm9fg52pcj360yj8024dzwpafya55")
        (npm-tarball "truncate-utf8-bytes/-/truncate-utf8-bytes-1.0.2.tgz"
                     "0r7bmf7faszkqd3calb35g92yf4113cxgs95ccxwdrjhd8rfcyii")
        (npm-tarball "ts-essentials/-/ts-essentials-10.1.1.tgz"
                     "0fm6i34x4z7rf0fsd8lc6r1zyqmpxvgbcjilp6iyczvjvfjr7y6p")
        (npm-tarball "tslib/-/tslib-1.14.1.tgz"
                     "1ywidp09jjarr031l03jg042zsfys2y2idwdcvmqhr7g54p32fvk")
        (npm-tarball "tslib/-/tslib-2.8.1.tgz"
                     "17hiw9pawyczkhsnhlq4k9dn3kq2l49nk5rlfn049bmbxvakbxk6")
        (npm-tarball "tsx/-/tsx-4.21.0.tgz"
                     "199kgy8a3q0h6xp8iyh94667rzmvxyzl4mmyvgnpdphni0hbh0yl")
        (npm-tarball "tsyringe/-/tsyringe-4.10.0.tgz"
                     "1km7fdlgp4335hwagbvzqbcxnzw3ycmm9pj33ayg3f1kwwqwv97w")
        (npm-tarball "tty-browserify/-/tty-browserify-0.0.1.tgz"
                     "1xqcmkdygz74fh4sfgbqwjxa8xpwlcyvbban6828iyc3dbikxi18")
        (npm-tarball "type-detect/-/type-detect-4.0.8.tgz"
                     "1xwws4l79rjn4qx5m9ixkgblv2sxas3n0bgfb55zjcg7gld117iz")
        (npm-tarball "type-detect/-/type-detect-4.1.0.tgz"
                     "0qwlhvc8pizka30hlsg8pyqjrll2q8vcbn1pgkjl877jmfzssw08")
        (npm-tarball "type-fest/-/type-fest-0.13.1.tgz"
                     "0xqlxm099arzx10i80vfygz6j6df1zqik6lnf8k1wc990aw6b77x")
        (npm-tarball "type-fest/-/type-fest-5.5.0.tgz"
                     "1gsc0i35vwjmlgdfiii4yklm53f1ag4bkjrl2w8kvx8z8bj1a903")
        (npm-tarball "type-is/-/type-is-2.0.1.tgz"
                     "1pbm95wdl9hmm93gmbdxyn00887l4r7jhia6dzgl99d89sx2kgqq")
        (npm-tarball "typed-array-buffer/-/typed-array-buffer-1.0.3.tgz"
                     "1bb1wminczciz8lrl8wsinc13wyymgxlnj8hjyl55bni8rc43sqg")
        (npm-tarball "typescript/-/typescript-5.9.3.tgz"
                     "1lx1hwb5g73x06pylqzgrkran1dlbx8iizrx0mwjhpvxrz4hiq8h")
        (npm-tarball "ufo/-/ufo-1.6.3.tgz"
                     "0ifjk9fzxghzv68azyc00pmj4xp1dmnc02hnkw4j9w3ny841kkqp")
        (npm-tarball "uncrypto/-/uncrypto-0.1.3.tgz"
                     "0w8cwj8fj888a7923igpyr4wnjhk58jmpbaqmf1arjx4x9bmz4y4")
        (npm-tarball "undici-types/-/undici-types-6.21.0.tgz"
                     "0vfidx8iwc7ab1p13fxy6bf35njqkii6nkwgah78b249w6jsk8fg")
        (npm-tarball "undici-types/-/undici-types-7.18.2.tgz"
                     "15sl89zgd53738z3bzx46hqp2zm2q4rz1vvh1yini5311sdpk4jd")
        (npm-tarball "unicode-properties/-/unicode-properties-1.4.1.tgz"
                     "0qlrhjjjz4mjlhgbrr45hb9falnnyiw3fbppij9xdi0jqxw89ynz")
        (npm-tarball "unicode-trie/-/unicode-trie-2.0.0.tgz"
                     "1dffvsb50qy1wpcc3zpakgrv3rk9ggpbai6m5g25w3ar5427bfbx")
        (npm-tarball "unicorn-magic/-/unicorn-magic-0.3.0.tgz"
                     "13lh0rv0k0bafp02x2krzk7vdj3qjd3ng0qrfd7z4kqlczlbpgz4")
        (npm-tarball "unique-filename/-/unique-filename-4.0.0.tgz"
                     "0la8cn1z4ppqflwal879q7rjgaxk62br38xqw6kikgpcvj2n4gdn")
        (npm-tarball "unique-slug/-/unique-slug-5.0.0.tgz"
                     "0q8qhnpdgv85nip6zcl5mzvbfrxlrcbrzgg6amr1s5fna2cl7k7w")
        (npm-tarball "universalify/-/universalify-0.1.2.tgz"
                     "0lykbpkmvjkjg0sqngrn086rxlyddgjkfnsi22r8hgixxzxb2alc")
        (npm-tarball "universalify/-/universalify-2.0.1.tgz"
                     "0rbqgcdmmz5kqjryyyjyjppa6d1kcxkmwj551cps2dhqnqxk21vx")
        (npm-tarball "unpipe/-/unpipe-1.0.0.tgz"
                     "1dnzbqfmchls4jyvkw0wnkc09pig98y66zzsy3lizgyls435xyrd")
        (npm-tarball "unzip-crx-3/-/unzip-crx-3-0.2.0.tgz"
                     "0b2c22v54397yapyqm6r7qc66b9qhjzx0xl6jvyk52v0hnyjjzjg")
        (npm-tarball "unzipper/-/unzipper-0.10.14.tgz"
                     "1iz7v3jdih4c05kaji2ig7j6g6ldqmba9fqc5mk9drchvlr58pkr")
        (npm-tarball "unzipper/-/unzipper-0.12.3.tgz"
                     "189nc08bfvl2kw5a31mibjnzp3rvjpds01qy1c2cijw8720pqmlc")
        (npm-tarball "update-browserslist-db/-/update-browserslist-db-1.2.3.tgz"
                     "1hs4d1y9z7wa44z7kppyid1rzg2ysi54wfs6s3slssimsh0dmbvb")
        (npm-tarball "urijs/-/urijs-1.19.11.tgz"
                     "1ybbi94a1jldcc5msw09k46n7hnx7dj5r5zmbmhwn6f3b3md0imi")
        (npm-tarball "url/-/url-0.11.4.tgz"
                     "0jh1wijsll888zbrlfbadi0nhky9m6m6npsmz1d9wsp2b06xdc0g")
        (npm-tarball "utf8-byte-length/-/utf8-byte-length-1.0.5.tgz"
                     "1cck9dmdsprgqafcah6vahr57jj905680ng3xazy7nvi89pggc5g")
        (npm-tarball "util-deprecate/-/util-deprecate-1.0.2.tgz"
                     "1rd3qbgdrwkmcrf7vqx61sh7icma7jvxcmklqj032f8v7jcdx8br")
        (npm-tarball "util/-/util-0.12.5.tgz"
                     "10mjb99581iwgpzng2gs1fwwgzkr673mqprmjmlnnzcz8k0xmffk")
        (npm-tarball "uuid-js/-/uuid-js-0.7.5.tgz"
                     "01cfvnm143vr66gjnb7ixxdckyzcgghg33rpa96vh3kj42pax44c")
        (npm-tarball "varint/-/varint-6.0.0.tgz"
                     "0088h8sszhv556zk99snvrfimmyj6skxy99ywmv7a7nyfcddzr06")
        (npm-tarball "vary/-/vary-1.1.2.tgz"
                     "0wbf4kmfyzc23dc0vjcmymkd1ks50z5gvv23lkkkayipf438cy3k")
        (npm-tarball "vite-hot-client/-/vite-hot-client-2.1.0.tgz"
                     "1fqn0nrkl6a90fh0mb5bc5b8jp7khipflaa14x692zxxfgkyn1qi")
        (npm-tarball "vite-node/-/vite-node-3.2.4.tgz"
                     "0yllricxryvgqkqspxg2aihc29ywn5ada9vfzms5i1hxfi0k97yl")
        (npm-tarball "vite-plugin-node-polyfills/-/vite-plugin-node-polyfills-0.23.1.tgz"
                     "0wf3hh067bwr7nm6r8ybf81rh0dscqiw8r8ny94q2fjfixmdmiq3")
        (npm-tarball "vite/-/vite-7.3.1.tgz"
                     "11gvh8vb20s0fngjk16idhak7wzgf6m8bck8rd6bbzl6l21c716v")
        (npm-tarball "vite/-/vite-8.0.2.tgz"
                     "02fbm9bisxdq5gw9s863860sh57nn1r98i3f7gsx04q97889fa35")
        (npm-tarball "vitest/-/vitest-3.2.4.tgz"
                     "1k9x0ybx1lvisf379ybv2ayk7ldh8zwv552asay97waq8d4l4qqm")
        (npm-tarball "vm-browserify/-/vm-browserify-1.1.2.tgz"
                     "0ihacds0jqql7zq97p1bg69a24fg526m57w6h2vhhv604cs3y4sn")
        (npm-tarball "vscode-uri/-/vscode-uri-3.1.0.tgz"
                     "0m7w7kj30ixmm49d47070vvg3hh5mkav8gxji5rj6n28g8npbv66")
        (npm-tarball "vue-component-type-helpers/-/vue-component-type-helpers-2.2.12.tgz"
                     "0v9jrg7bi4nwnssjvvj4qk62grwqn0rvvvqkhlchyr007xn6h7am")
        (npm-tarball "vue-i18n/-/vue-i18n-11.3.0.tgz"
                     "0z3n3mcxsjwbnf9ryqlmdlzv41q4npsqmzi91iybn7qxm1b2d7qx")
        (npm-tarball "vue-resize/-/vue-resize-2.0.0-alpha.1.tgz"
                     "1dfa86ibiszfs17l7x9zgq9669yamgpk719g3nfvq3hy0r6yprgg")
        (npm-tarball "vue-router/-/vue-router-4.6.4.tgz"
                     "1jf99jaay7d6pd5ql4xz98kd404hvy2qaw76vw5ljdsw3166q6w3")
        (npm-tarball "vue-template-compiler/-/vue-template-compiler-2.7.16.tgz"
                     "10c9wsqnc2xal265gfngklqsn3xqr9xw2n1ghrncfkxv59yrphpd")
        (npm-tarball "vue-tsc/-/vue-tsc-3.3.6.tgz"
                     "16yvz2hjhgam79zn3528kwysx4127ljfiv3ff7c9fhwyyqhwikbm")
        (npm-tarball "vue/-/vue-3.5.31.tgz"
                     "09q43yl77cq862w74ysqbarhp16vpfqpq5y4j7v9hby72kcyly1h")
        (npm-tarball "vuedraggable/-/vuedraggable-4.1.0.tgz"
                     "0pm377d9z8slhv4bm9shbnm40dl4mifk535xlvvxajx6x76mma2q")
        (npm-tarball "vuex/-/vuex-4.1.0.tgz"
                     "0f0r19kwmwn8d7xfd61nrlc7yyjjsiczf8bymszy71n29qqq9q7l")
        (npm-tarball "wallaby-vue-compiler/-/wallaby-vue-compiler-1.0.6.tgz"
                     "035525ryx2cn9dmkgwj8pln0n6kwh1sw5d8v1678fsfrd2n3avn1")
        (npm-tarball "wcwidth/-/wcwidth-1.0.1.tgz"
                     "1a53pbnxfmhnlvzzgq8p8yqh0gzlsibj7263gx8s86q63v1wna4z")
        (npm-tarball "webcrypto-core/-/webcrypto-core-1.9.2.tgz"
                     "00lbz94dd97zjylykaih7yvi7wm65mzsy508yp2kf2lxglxcd1hv")
        (npm-tarball "webidl-conversions/-/webidl-conversions-3.0.1.tgz"
                     "1a1dwb1ga1cj2s7av9r46b4xmx11vsk5zncc0gq2qz4l815w7pz4")
        (npm-tarball "webpack-merge/-/webpack-merge-6.0.1.tgz"
                     "0li4k3c1j3qndqkqr0fpa29vsk0ddyk67r56qlwqiizj10ymzkpl")
        (npm-tarball "whatwg-url/-/whatwg-url-5.0.0.tgz"
                     "1lvyrf4ry4bgl2jgpim2pkdmrbv2vb0vh0irmkp7da3kymqw97dh")
        (npm-tarball "which-typed-array/-/which-typed-array-1.1.20.tgz"
                     "05fmgcwikawgn8cs2d9mpg05z503khk81d77c42jazjwds21pm8z")
        (npm-tarball "which/-/which-2.0.2.tgz"
                     "1p2fkm4lr36s85gdjxmyr6wh86dizf0iwmffxmarcxpbvmgxyfm1")
        (npm-tarball "which/-/which-5.0.0.tgz"
                     "0jsfpp5fcq7f6yhg1mk5s06nhhdjyqqm3fj849i4g9041f3l2xzj")
        (npm-tarball "why-is-node-running/-/why-is-node-running-2.3.0.tgz"
                     "0qwrxh3bl4mdf9cb1y4ls57gddgmr5x621ggg409sl2kg7vnixnj")
        (npm-tarball "wildcard/-/wildcard-2.0.1.tgz"
                     "0mk8zv5jgi1b03hzxxc7x3f6n7silrl292q33kyxj1syrdhc3fhq")
        (npm-tarball "wordwrap/-/wordwrap-1.0.0.tgz"
                     "0f08g3gb6si97h2faw175isf8k7hjbnw5rr2bm4wcr1141lzd0f3")
        (npm-tarball "wrap-ansi/-/wrap-ansi-7.0.0.tgz"
                     "0bx4bkwfli34343rl97qy5pdg3zmskinsf8mlkv3isfj1d8v7587")
        (npm-tarball "wrap-ansi/-/wrap-ansi-8.1.0.tgz"
                     "0vdcnhg24yfbwnp0xxgpnzafn018bhh7s2yff5fyr3f2pabjn6zp")
        (npm-tarball "wrap-ansi/-/wrap-ansi-9.0.2.tgz"
                     "0zlfyx06anlvz5rq9631r5qhjqhixxxalx8sd526b4z0rv2sahha")
        (npm-tarball "wrappy/-/wrappy-1.0.2.tgz"
                     "1yzx63jf27yz0bk0m78vy4y1cqzm113d2mi9h91y3cdpj46p7wxg")
        (npm-tarball "ws/-/ws-8.18.3.tgz"
                     "0amym7wbm2q1jl1y6bx6rqxsymn2vbr7n1hzkb16z4p7r02fcjs2")
        (npm-tarball "wsl-utils/-/wsl-utils-0.3.1.tgz"
                     "1z1wzzp1bdq5micw3xpl93ivqnn1w2ksjj0rnqdh35jxd1q6lib2")
        (npm-tarball "xmlbuilder/-/xmlbuilder-15.1.1.tgz"
                     "17p1k7a172zsf9lj691mxvkj1xnr9ljmvfjjfhq3c6zr882hbi75")
        (npm-tarball "xmlhttprequest-ssl/-/xmlhttprequest-ssl-2.1.2.tgz"
                     "0kzpq4xs34c0m09nr8qrzpvpa2giza8jq1f2asgnkm985jc08ilf")
        (npm-tarball "xtend/-/xtend-4.0.2.tgz"
                     "0j5s840a0a3mjzxixr95jpila80kbdvrxyixnmxvx6f78cfs08mx")
        (npm-tarball "y18n/-/y18n-5.0.8.tgz"
                     "0sd7mpg2c0fxqq4q2574hvm26fgy6byp1gxnsgskmjx7sfx46dyl")
        (npm-tarball "yaku/-/yaku-0.16.7.tgz"
                     "0nrz9vkm67849mwhi1zq1i9nmvrwsk33cq9y7ha6ynrx7cmbj45q")
        (npm-tarball "yallist/-/yallist-3.1.1.tgz"
                     "016afm3iv7pfrg9nj7952dph6sg00lryk8wv4nr0qdp8rzk4mwah")
        (npm-tarball "yallist/-/yallist-4.0.0.tgz"
                     "0jadz9mh1lzfk19bvqqlrg40ggfk2yyfyrpgj5c62dk54ym7h358")
        (npm-tarball "yallist/-/yallist-5.0.0.tgz"
                     "15ffxgcsvvq8yp4rxcqnacl84i012jpsbrmh6cqkpavwmgdl77bw")
        (npm-tarball "yaml/-/yaml-1.10.3.tgz"
                     "1qj5vnqrvbx4r49wpj5bsdiy11iz7cn9khgkaf52094a6wqicnsk")
        (npm-tarball "yaml/-/yaml-2.8.3.tgz"
                     "1bc5pw65zwxjf8sdkidbh1g2qdl3qanard65snzg5pj7fifq0fcm")
        (npm-tarball "yargs-parser/-/yargs-parser-21.1.1.tgz"
                     "0lcif2zbzw2jfj63paq2wdgc1hs9fd8i2xzjcidjcwjagm97sarl")
        (npm-tarball "yargs-parser/-/yargs-parser-22.0.0.tgz"
                     "0radc7hzqmbdbgxr3x36vd39mrgamydskzldf0658vyap53h4r1b")
        (npm-tarball "yargs/-/yargs-17.7.2.tgz"
                     "1jdfhg5pvp8834zsbm0vibjxx9rpwargqw1619i61mxm21gr7v28")
        (npm-tarball "yargs/-/yargs-18.0.0.tgz"
                     "0l1khnsh11sn05kwkbiar743rjxrc3mna0h4wwfx1iqnmzahp04r")
        (npm-tarball "yauzl/-/yauzl-2.10.0.tgz"
                     "1cbcq82bafcifhliglwjzp6b898qawrzng8315rh0r3vbn1k23sm")
        (npm-tarball "yocto-queue/-/yocto-queue-0.1.0.tgz"
                     "1w99c4y6vl1q5dmw9hnkbiqxnmaz72x22qdc13mg084glpnbqwn7")
        (npm-tarball "yoctocolors/-/yoctocolors-2.1.2.tgz"
                     "1w44xaicsrygvlssrp2d4a256h6m8fl1s435sa51g27wfl5s86rw")
        (npm-tarball "zip-stream/-/zip-stream-6.0.1.tgz"
                     "0kihk6nndqqz3y7i7vjwn8a1k2fn1ay91sidxfrrl0sm6mv12w8q")))

(define r2modman-pnpm-tarball
  (cdr (npm-tarball "pnpm/-/pnpm-11.8.0.tgz"
                    "161f1rr7vwpz90xydz5pfaq759vkv3l4xz03p988a5m59if3m5hy")))
