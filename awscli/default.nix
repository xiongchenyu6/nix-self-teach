with import <nixpkgs> {};
let  myPythonPackages = pythonPackages.override {
    overrides = self: super: {
       botocore = super.botocore.overrideAttrs (oldAttrs: {
        src = fetchgit {
          url = "https://github.com/boto/botocore";
          rev = "568636edf10394332792bc122dfc4a33242708ab";
          sha256 = "09w6izvi2zgfg7lxrwh0n5rq7ynxj46pg63lyvs11qg5nm5fhvrn";
        };
        propagatedBuildInputs = [
          super.python-dateutil
          super.jmespath
          super.docutils
          super.urllib3
        ];
      });
       s3transfer = super.s3transfer.overrideAttrs (oldAttrs: {
        src = fetchgit {
          url = "https://github.com/boto/s3transfer";
          rev = "f506f396f054d35288bcf86d5289f8749a366ccd";
          sha256 = "0jqaw06dgpv4g6arvlvxp6fz509zzal3mc1nn6xaabwahck7inx2";
        };});
    };
  };
in 
  with myPythonPackages;
  buildPythonPackage rec {
  pname = "awscli";
  version = "1.16.55";

  src = fetchPypi {
    inherit pname version;
    sha256 = "14yakyc8sldqsvyh470jp29kksgkwqj5lj7mvpg2l2v3plvay7v2";
  };

  # No tests included
  doCheck = false;

  propagatedBuildInputs = [
    python-dateutil
    botocore
    colorama
    docutils
    rsa
    s3transfer
    pyyaml
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${groff}/bin:${less}/bin"
  ];

  postInstall = ''
    mkdir -p $out/etc/bash_completion.d
    echo "complete -C $out/bin/aws_completer aws" > $out/etc/bash_completion.d/awscli
    mkdir -p $out/share/zsh/site-functions
    mv $out/bin/aws_zsh_completer.sh $out/share/zsh/site-functions
    rm $out/bin/aws.cmd
  '';

  meta = with lib; {
    homepage = https://aws.amazon.com/cli/;
    description = "Unified tool to manage your AWS services";
    license = licenses.asl20;
    maintainers = with maintainers; [ muflax ];
  };
}
