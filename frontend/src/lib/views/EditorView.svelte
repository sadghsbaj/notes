<script lang="ts">
    import DirtyIndicator from "$features/editor/components/DirtyIndicator.svelte";
    import Editor from "$features/editor/components/Editor.svelte";
    import Tabs from "$features/editor/components/Tabs.svelte";
</script>

<div class="mx-auto py-8 flex flex-col gap-5 h-full max-w-6xl w-full">
    <Tabs />

    <Editor />

    <DirtyIndicator />
</div>
