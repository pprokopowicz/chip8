pub const DisplayError = error{
    FailedToInitialize,
    FailedToCreateWindow,
    FailedToCreateRenderer,
    FailedToCreateTexture,
};

pub const RenderError = error{
    FailedToLockTexture,
    FailedToClearRenderer,
    FailedToRenderTexture,
    FailedToPresentRenderer,
};
