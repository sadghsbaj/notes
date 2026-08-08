<script lang="ts">
    import { Settings2 } from "@lucide/svelte";

    import DirtyIndicator from "$features/editor/components/DirtyIndicator.svelte";
    import Editor from "$features/editor/components/Editor.svelte";
    import Tabs from "$features/editor/components/Tabs.svelte";

    import IconButton from "$components/app/IconButton.svelte";

    import { viewState } from "./view.svelte";
</script>

<div class="mx-auto py-8 flex flex-col gap-5 h-full max-w-6xl w-full">
    <Tabs />

    <Editor />

    <DirtyIndicator />

    <IconButton placement="right" icon={Settings2} action={() => viewState.setView("settings")} />
</div>
