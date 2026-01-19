SELECT tmp.Suchlauf, tmp.WholeWord
FROM _FindReplace AS tmp
WHERE (((tmp.Suchlauf) In (SELECT [Suchlauf] FROM [_FindReplace] WHERE [WholeWord] = [tmp].[WholeWord] GROUP BY [Suchlauf],[WholeWord] HAVING Count(*)>1)))
ORDER BY tmp.Suchlauf, tmp.WholeWord;

