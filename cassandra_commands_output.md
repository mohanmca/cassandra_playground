```bash
# nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
UN  172.19.0.3  5.85 MiB   256          46.7%             2b3576cd-3f5d-4b9c-80bf-9c5a5fce7dc5  rack1
UN  172.19.0.2  6.65 MiB   256          53.3%             4936c442-00c7-4242-87cb-4cf265c5ae78  rack1

# nodetool ring | grep "172.19.0.3" | wc -l
256

# nodetool ring

Datacenter: datacenter1
==========
Address     Rack        Status State   Load            Owns                Token
                                                                           9126432156340756354
172.19.0.2  rack1       Up     Normal  6.65 MiB        53.31%              -9163250791483814686
172.19.0.3  rack1       Up     Normal  5.85 MiB        46.69%              -9137673090615533091
172.19.0.2  rack1       Up     Normal  6.65 MiB        53.31%              -9083337207055421835
172.19.0.2  rack1       Up     Normal  6.65 MiB        53.31%              -8994933303427082675
172.19.0.3  rack1       Up     Normal  5.85 MiB        46.69%              -8931107877434468662
172.19.0.3  rack1       Up     Normal  5.85 MiB        46.69%              -8862098302720005632
172.19.0.2  rack1       Up     Normal  6.65 MiB        53.31%              -8835701033996281573
172.19.0.3  rack1       Up     Normal  5.85 MiB        46.69%              -8779311204712756082

# nodetool gossipinfo
/172.19.0.3
  generation:1573517338
  heartbeat:1729
  STATUS:15:NORMAL,-104443974761627325
  LOAD:1694:6131589.0
  SCHEMA:11:3e2505d7-5286-3090-bc68-d01d101c68db
  DC:7:datacenter1
  RACK:9:rack1
  RELEASE_VERSION:5:3.11.5
  RPC_ADDRESS:4:172.19.0.3
  NET_VERSION:2:11
  HOST_ID:3:2b3576cd-3f5d-4b9c-80bf-9c5a5fce7dc5
  RPC_READY:27:true
  TOKENS:14:<hidden>
/172.19.0.2
  generation:1573517338
  heartbeat:1728
  STATUS:15:NORMAL,-103897790007775916
  LOAD:1694:6974127.0
  SCHEMA:11:3e2505d7-5286-3090-bc68-d01d101c68db
  DC:7:datacenter1
  RACK:9:rack1
  RELEASE_VERSION:5:3.11.5
  RPC_ADDRESS:4:172.19.0.2
  NET_VERSION:2:11
  HOST_ID:3:4936c442-00c7-4242-87cb-4cf265c5ae78
  RPC_READY:27:true
  TOKENS:14:<hidden>

#  nodetool gossipinfo
/172.19.0.3
  generation:1573519222
  heartbeat:17
  STATUS:15:NORMAL,-104443974761627325
  LOAD:19:6396507.0
  SCHEMA:11:3e2505d7-5286-3090-bc68-d01d101c68db
  DC:7:datacenter1
  RACK:9:rack1
  RELEASE_VERSION:5:3.11.5
  RPC_ADDRESS:4:172.19.0.3
  NET_VERSION:2:11
  HOST_ID:3:2b3576cd-3f5d-4b9c-80bf-9c5a5fce7dc5
  TOKENS:14:<hidden>
/172.19.0.2
  generation:1573517338
  heartbeat:1971
  STATUS:15:NORMAL,-103897790007775916
  LOAD:1946:6974127.0
  SCHEMA:11:3e2505d7-5286-3090-bc68-d01d101c68db
  DC:7:datacenter1
  RACK:9:rack1
  RELEASE_VERSION:5:3.11.5
  RPC_ADDRESS:4:172.19.0.2
  NET_VERSION:2:11
  HOST_ID:3:4936c442-00c7-4242-87cb-4cf265c5ae78
  RPC_READY:27:true
  TOKENS:14:<hidden>

#  nodetool gossipinfo
/172.19.0.3
  generation:1573519222
  heartbeat:32
  STATUS:15:NORMAL,-104443974761627325
  LOAD:19:6396507.0
  SCHEMA:11:3e2505d7-5286-3090-bc68-d01d101c68db
  DC:7:datacenter1
  RACK:9:rack1
  RELEASE_VERSION:5:3.11.5
  RPC_ADDRESS:4:172.19.0.3
  NET_VERSION:2:11
  HOST_ID:3:2b3576cd-3f5d-4b9c-80bf-9c5a5fce7dc5
  RPC_READY:27:true
  TOKENS:14:<hidden>
/172.19.0.2
  generation:1573517338
  heartbeat:1982
  STATUS:15:NORMAL,-103897790007775916
  LOAD:1946:6974127.0
  SCHEMA:11:3e2505d7-5286-3090-bc68-d01d101c68db
  DC:7:datacenter1
  RACK:9:rack1
  RELEASE_VERSION:5:3.11.5
  RPC_ADDRESS:4:172.19.0.2
  NET_VERSION:2:11
  HOST_ID:3:4936c442-00c7-4242-87cb-4cf265c5ae78
  RPC_READY:27:true
  TOKENS:14:<hidden>  

#

```  