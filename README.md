s3_backup
=========

Create encrypted backups once a day and push them into S3.
Last 14 versions will be kept.

In order to work properly you must specify following variables:
* `s3_backup_access_key` (string)
* `s3_backup_secret_key` (string)
* `s3_backup_configs` (complex)

Requirements
------------

S3 Endpoint must support [SSE-C](https://docs.aws.amazon.com/AmazonS3/latest/dev/ServerSideEncryptionCustomerKeys.html).

Role Variables
--------------

| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `s3_backup_region` | string | `us-east-1` | Default region |
| `s3_backup_endpoint` | string | `s3.amazonaws.com` | Endpoint to connect to. Works with S3-Compatible endpoinds as well (At least cephs rados s3) |
| `s3_backup_access_key` | string | "" | Access Key |
| `s3_backup_secret_key` |string | "" | Secret Key |
| `s3_backup_credentials` | dict | { aws_access_key_id: "{{ s3_backup_access_key }}", aws_secret_access_key: "{{ s3_backup_secret_key }}" } | Wrapper for writing access and secret key into credentials config |
| `s3_backup_configs` | complex | {} | Configuration for Backups. Each element must contain `name`, `src`, `dst`, `key`.  See Example Playbook |

Dependencies
------------

None so far...

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      vars:
        s3_backup_access_key: AAABBBCCC
        s3_backup_secret_key: DDDEEEFFF
        s3_backup_configs:
          - name: gitlab-config
            src: /etc/gitlab/
            dst: gitlab-config
            key: abcdefgh12345678abcdefgh12345678
          - name: icinga2-ca
            src: /var/lib/icinga2/ca/
            dst: icinga2-ca
            key: abcdefgh12345678abcdefgh12345678
      roles:
         - derJD.s3_backup

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
