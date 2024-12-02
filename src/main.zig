const std = @import("std");
const day1 = @import("solutions/day1.zig");

pub fn main() !void {
    const data = try day1.dataFromFile();
    const res = try day1.solution(data.left_list, data.right_list);

    std.debug.print("Day1 result. Part1: {}, part2: {}\n", .{ res.part1, res.part2 });
}

test "simple test" {}
