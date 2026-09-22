using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ProjectHub.Api.Migrations
{
    /// <inheritdoc />
    public partial class MigrateTaskStatusAndPriorityToEnums : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Tasks_ProjectId",
                table: "Tasks");

            // 1. Pre-migration verification
            migrationBuilder.Sql(@"
                DO $$
                BEGIN
                    IF EXISTS (
                        SELECT 1 FROM ""Tasks"" 
                        WHERE ""Status"" NOT IN ('Backlog', 'Todo', 'InProgress', 'Review', 'Done')
                           OR ""Priority"" NOT IN ('Low', 'Medium', 'High', 'Urgent')
                    ) THEN
                        RAISE EXCEPTION 'Cannot migrate: unexpected status or priority string found in Tasks table.';
                    END IF;
                END $$;");

            // 2. Convert Status to smallint via USING clause
            migrationBuilder.Sql(@"
                ALTER TABLE ""Tasks"" 
                ALTER COLUMN ""Status"" TYPE smallint 
                USING CASE ""Status""
                    WHEN 'Backlog' THEN 0
                    WHEN 'Todo' THEN 1
                    WHEN 'InProgress' THEN 2
                    WHEN 'Review' THEN 3
                    WHEN 'Done' THEN 4
                    ELSE 0
                END;");

            // 3. Convert Priority to smallint via USING clause
            migrationBuilder.Sql(@"
                ALTER TABLE ""Tasks"" 
                ALTER COLUMN ""Priority"" TYPE smallint 
                USING CASE ""Priority""
                    WHEN 'Low' THEN 0
                    WHEN 'Medium' THEN 1
                    WHEN 'High' THEN 2
                    WHEN 'Urgent' THEN 3
                    ELSE 1
                END;");

            migrationBuilder.CreateIndex(
                name: "IX_Tasks_ProjectId_Status",
                table: "Tasks",
                columns: new[] { "ProjectId", "Status" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Tasks_ProjectId_Status",
                table: "Tasks");

            migrationBuilder.Sql(@"
                ALTER TABLE ""Tasks"" 
                ALTER COLUMN ""Status"" TYPE character varying(50) 
                USING CASE ""Status""
                    WHEN 0 THEN 'Backlog'
                    WHEN 1 THEN 'Todo'
                    WHEN 2 THEN 'InProgress'
                    WHEN 3 THEN 'Review'
                    WHEN 4 THEN 'Done'
                    ELSE 'Backlog'
                END;");

            migrationBuilder.Sql(@"
                ALTER TABLE ""Tasks"" 
                ALTER COLUMN ""Priority"" TYPE character varying(50) 
                USING CASE ""Priority""
                    WHEN 0 THEN 'Low'
                    WHEN 1 THEN 'Medium'
                    WHEN 2 THEN 'High'
                    WHEN 3 THEN 'Urgent'
                    ELSE 'Medium'
                END;");

            migrationBuilder.CreateIndex(
                name: "IX_Tasks_ProjectId",
                table: "Tasks",
                column: "ProjectId");
        }
    }
}
