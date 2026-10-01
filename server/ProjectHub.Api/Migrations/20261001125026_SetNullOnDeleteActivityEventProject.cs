using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ProjectHub.Api.Migrations
{
    /// <inheritdoc />
    public partial class SetNullOnDeleteActivityEventProject : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ActivityEvents_Projects_ProjectId",
                table: "ActivityEvents");

            migrationBuilder.AddForeignKey(
                name: "FK_ActivityEvents_Projects_ProjectId",
                table: "ActivityEvents",
                column: "ProjectId",
                principalTable: "Projects",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ActivityEvents_Projects_ProjectId",
                table: "ActivityEvents");

            migrationBuilder.AddForeignKey(
                name: "FK_ActivityEvents_Projects_ProjectId",
                table: "ActivityEvents",
                column: "ProjectId",
                principalTable: "Projects",
                principalColumn: "Id");
        }
    }
}
