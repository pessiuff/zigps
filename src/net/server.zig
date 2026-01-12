const std = @import("std");

const enet = @import("enet_wrapper.zig").enet;

pub const gtps = struct {
    pub const Server = struct {
        enet_host: enet.ENetHost,

        pub fn init() !Server {
            try enet.oneTimeInit();

            var server = Server{ .enet_host = try enet.ENetHost.createHostSimple(1337, 512, 2) };
            server.enet_host.useCRC32();
            try server.enet_host.useRangeCoder();

            return server;
        }

        pub fn pollEvents(self: *Server, timeout: u32) !void {
            while (try self.enet_host.pollEvents(timeout)) |event| {
                _ = event.peer;
                var packet = event.packet;
                switch (event.type) {
                    .connect => {
                        std.log.debug("A client has connected.", .{});
                    },
                    .disconnect => {
                        std.log.debug("A client has disconnected.", .{});
                    },
                    .receive => {
                        std.log.debug("A client has sent a packet.", .{});
                        packet.?.destroy();
                    },
                }
            }
        }

        pub fn deinit(self: *Server) void {
            self.enet_host.destroy();
            enet.oneTimeDeinit();
        }
    };
};
