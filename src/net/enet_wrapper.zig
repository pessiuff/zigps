pub const c_enet = @cImport({
    @cInclude("enet/enet.h");
});

pub const enet = struct {
    pub const ENetError = error{ InitializationFailure, HostCreationFailure, CompressionSetupFailure, PollingError };

    pub const ENetEventType = enum { connect, disconnect, receive };

    pub const ENetPeer = struct {
        c_enet_peer: [*c]c_enet.ENetPeer,
    };

    pub const ENetPacket = struct {
        c_enet_packet: [*c]c_enet.ENetPacket,

        pub fn destroy(self: *ENetPacket) void {
            c_enet.enet_packet_destroy(self.c_enet_packet);
            self.c_enet_packet = null;
        }
    };

    pub const ENetEvent = struct {
        type: ENetEventType,
        peer: ENetPeer,
        packet: ?ENetPacket,
    };

    pub const ENetHost = struct {
        c_enet_host: [*c]c_enet.ENetHost,

        pub fn createHostSimple(port: u16, max_peer_count: usize, channel_count: usize) !ENetHost {
            var server_address = c_enet.ENetAddress{};
            server_address.host = c_enet.ENET_HOST_ANY;
            server_address.port = port;

            const server_host = c_enet.enet_host_create(&server_address, max_peer_count, channel_count, 0, 0) orelse {
                return ENetError.HostCreationFailure;
            };
            return .{ .c_enet_host = server_host };
        }

        pub fn createHostAdvanced(ip: [:0]const u8, port: u16, max_peer_count: usize, channel_count: usize, max_incoming_bandwidth: u32, max_outgoing_bandwidth: u32) !ENetHost {
            var server_address = c_enet.ENetAddress{};
            c_enet.enet_address_set_host_ip(&server_address, ip.ptr);
            server_address.port = port;

            const server_host = c_enet.enet_host_create(&server_address, max_peer_count, channel_count, max_incoming_bandwidth, max_outgoing_bandwidth) orelse {
                return ENetError.HostCreationFailure;
            };
            return .{ .c_enet_host = server_host };
        }

        pub fn useCRC32(self: *ENetHost) void {
            self.c_enet_host.*.checksum = c_enet.enet_crc32;
        }

        pub fn useRangeCoder(self: *ENetHost) !void {
            if (c_enet.enet_host_compress_with_range_coder(self.c_enet_host) != 0) {
                return ENetError.CompressionSetupFailure;
            }
        }

        pub fn pollEvents(self: *ENetHost, timeout: u32) !?ENetEvent {
            var c_enet_event = c_enet.ENetEvent{};
            const poll_result: i32 = c_enet.enet_host_service(self.c_enet_host, &c_enet_event, timeout);
            if (poll_result > 0) {
                switch (c_enet_event.type) {
                    c_enet.ENET_EVENT_TYPE_CONNECT => {
                        return ENetEvent{ .type = .connect, .peer = ENetPeer{ .c_enet_peer = c_enet_event.peer }, .packet = null };
                    },
                    c_enet.ENET_EVENT_TYPE_DISCONNECT => {
                        return ENetEvent{ .type = .disconnect, .peer = ENetPeer{ .c_enet_peer = c_enet_event.peer }, .packet = null };
                    },
                    c_enet.ENET_EVENT_TYPE_RECEIVE => {
                        return ENetEvent{ .type = .receive, .peer = ENetPeer{ .c_enet_peer = c_enet_event.peer }, .packet = ENetPacket{ .c_enet_packet = c_enet_event.packet } };
                    },
                    else => {
                        return null;
                    },
                }
            } else if (poll_result == 0) {
                return null;
            } else {
                return ENetError.PollingError;
            }
        }

        pub fn destroy(self: *ENetHost) void {
            c_enet.enet_host_destroy(self.c_enet_host);
            self.c_enet_host = null;
        }
    };

    pub fn oneTimeInit() !void {
        if (c_enet.enet_initialize() != 0) {
            return ENetError.InitializationFailure;
        }
    }

    pub fn oneTimeDeinit() void {
        c_enet.enet_deinitialize();
    }
};
