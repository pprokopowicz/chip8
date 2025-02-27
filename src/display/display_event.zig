pub const DisplayEvent = union(enum) {
    quit: void,
    key_down: u32,
    key_up: u32,
    none: void,
};
