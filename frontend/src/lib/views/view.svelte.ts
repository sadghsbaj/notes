import { createViewState } from "$core/_system/layout/app-views/view-state/viewState.svelte";

export const viewState = createViewState({
    persistKey: "svelte-template-views",
    views: [
    ] as const,
});
