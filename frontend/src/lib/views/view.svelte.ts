import { createViewState } from "$core/_system/layout/app-views/view-state/viewState.svelte";

export const viewState = createViewState({
    persistKey: "svelte-template-views",
    views: [
        {
            view: "editor",
            parent: "root",
        },
        {
            view: "settings",
            parent: "root",
        },
    ] as const,
});
