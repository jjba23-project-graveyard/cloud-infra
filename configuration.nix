# Joe's Cloud Infra
# Copyright (C) 2024  Josep Jesus Bigorra Algaba (jjbigorra@gmail.com)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

{ lib, ... }:

let
  s3 = import ./src/aws/s3.nix { inherit lib; };
  route53 = import ./src/aws/route53.nix { inherit lib; };
  iam = import ./src/aws/iam.nix { inherit lib; };

  region = "eu-west-3";
  alternativeRegion = "us-east-1";

  prod = "Production";
  contaboIp = "37.60.232.48";

  records = [
    {
      name = "_dmarc.jointhefreeworld.org";
      type = "TXT";
      value = "v=DMARC1; p=none;";
      zone = "jointhefreeworld.org";
    }
    {
      name = "jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
    {
      name = "www.jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
    {
      name = "wikimusic.jointhefreeworld.org";
      value = contaboIp;
      zone = "jointhefreeworld.org";
      type = "A";
    }
    {
      name = "www.wikimusic.jointhefreeworld.org";
      value = contaboIp;
      zone = "jointhefreeworld.org";
      type = "A";
    }
    {
      name = "oculuslambda.jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
    {
      name = "www.oculuslambda.jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
    {
      name = "pingwing.jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
    {
      name = "casadelcata.es";
      zone = "casadelcata.es";
      value = contaboIp;
      type = "A";
    }
    {
      name = "www.casadelcata.es";
      zone = "casadelcata.es";
      value = contaboIp;
      type = "A";
    }
    {
      name = "carvoeirowaterfun.com";
      zone = "carvoeirowaterfun.com";
      value = contaboIp;
      type = "A";
    }
    {
      name = "www.carvoeirowaterfun.com";
      zone = "carvoeirowaterfun.com";
      value = contaboIp;
      type = "A";
    }
    {
      name = "byggsteg.jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
    {
      name = "www.byggsteg.jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
    {
      name = "lucidplan.jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
    {
      name = "www.lucidplan.jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
    {
      name = "hygguile.jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
    {
      name = "www.hygguile.jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
    {
      name = "rchuidkliniek.beta.jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
    {
      name = "minecraft-server.jointhefreeworld.org";
      zone = "jointhefreeworld.org";
      value = contaboIp;
      type = "A";
    }
  ];

  buckets = [
    {
      bucket = "cloud-infra-state-jjba";
      description = "Cloud Infrastructure State";
      env = prod;
      isVersionedBucket = true;
    }
    {
      bucket = "wolk-jjba-backups";
      description = "Wolk JJBA Backups";
      env = prod;
      isVersionedBucket = false;
    }
  ];

  zones = [
    {
      zone = "jointhefreeworld.org";
      env = prod;
    }
    {
      zone = "casadelcata.es";
      env = prod;
    }
    {
      zone = "carvoeirowaterfun.com";
      env = prod;
    }
  ];

  groups = [
    {
      name = "mail-senders";
      path = "/automation/";
      policyName = "mail-senders";
      policyStatements = [{
        Effect = "Allow";
        Action = [ "ses:*" ];
        Resource = "*";
      }];
    }
    {
      name = "backer-uppers";
      path = "/automation/";
      policyName = "backer-uppers";
      policyStatements = [{
        Effect = "Allow";
        Action = [ "s3:*" ];
        Resource = "*";
      }];
    }
  ];

  users = [
    {
      name = "mail-sender";
      path = "/automation/";
      groups = [ "mail-senders" ];
      tags = { };
    }
    {
      name = "backer-upper";
      path = "/automation/";
      groups = [ "backer-uppers" ];
      tags = { };
    }
  ];

  resources = [
    (map s3.mkBucket buckets)
    (map route53.mkZone zones)
    (map route53.mkRecord records)
    (map iam.mkUserGroup groups)
    (map iam.mkUser users)
  ];

in {
  provider.aws = [
    { inherit region; }
    {
      alias = "us";
      region = alternativeRegion;
    }
  ];

  resource = lib.mkMerge (lib.lists.flatten resources);
  data = lib.mkMerge [ ];
}
