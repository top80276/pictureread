namespace FileStoreApi
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // CORS Allow *
            builder.Services.AddCors(option => {
                option.AddPolicy(name: "MyPolicy", policy =>
                {
                    policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod();
                });
            });


            // Add services to the container.
            builder.Services.AddControllers();
            builder.Configuration.AddJsonFile("appsettings.json");


            var app = builder.Build();

            // Configure the HTTP request pipeline.

            app.UseHttpsRedirection();

            app.UseAuthorization();

            //: CORS Apply Globa
            app.UseCors("MyPolicy");

            app.MapControllers();

            app.Run();
        }
    }
}