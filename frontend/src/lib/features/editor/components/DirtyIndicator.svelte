<script lang="ts">
    import { editorState } from "$features/editor/editorState.svelte";
</script>

<div
    class="border rounded-full h-4 w-4 bottom-4 right-4 fixed {editorState.isDirty
        ? 'border-warning-500 bg-warning-200 dark:border-warning-400 dark:bg-warning-500/20'
        : 'border-success-500 bg-success-200 dark:border-success-400 dark:bg-success-500/20'}"
></div>
