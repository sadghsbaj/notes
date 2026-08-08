<script lang="ts">
    import { onMount } from "svelte";

    import { initPreload } from "$core/_system";
    import FocusHost from "$core/_system/focus/FocusHost.svelte";
    import AppLayer from "$core/_system/layout/app-layer/AppLayer.svelte";
    import AppView from "$core/_system/layout/app-views/AppView.svelte";
    import AppViews from "$core/_system/layout/app-views/AppViews.svelte";
    import PerformanceHost from "$core/_system/performance/PerformanceHost.svelte";
    import EditorView from "$views/EditorView.svelte";
    import SettingsView from "$views/SettingsView.svelte";
    import { viewState } from "$views/view.svelte";

    onMount(() => {
        return initPreload();
    });
</script>

<div class="flex h-screen w-screen overflow-hidden">
    <AppViews {viewState}>
        <AppView view="editor">
            <EditorView />
        </AppView>

        <AppView view="settings">
            <SettingsView />
        </AppView>
    </AppViews>
</div>

<!-- AppLayers -->
<AppLayer z="top-layer" layer="focus">
    <FocusHost />
</AppLayer>

{#if import.meta.env.DEV}
    <AppLayer z={9000} layer="performance">
        <PerformanceHost />
    </AppLayer>
{/if}

<!-- /AppLayers -->
